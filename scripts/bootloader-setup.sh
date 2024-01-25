#!/bin/bash

# Function to check command existence
ensure_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "Command not found: $1"
        exit 1
    fi
}

# Check for required commands
ensure_command blkid
ensure_command df
ensure_command btrfs
ensure_command sed
ensure_command refind-install
ensure_command bootctl

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
    exit 1
fi

# Identify the root partition's UUID and Filesystem Type
root_source=$(df --output=source / | tail -1)
root_uuid=$(blkid -o value -s UUID "$root_source") || { echo "Failed to find root UUID."; exit 1; }
root_fstype=$(blkid -o value -s TYPE "$root_source") || { echo "Failed to find root filesystem type."; exit 1; }

# If root is on Btrfs, find the subvolume
if [ "$root_fstype" == "btrfs" ]; then
    root_subvol=$(btrfs subvolume get-default / | awk -F ' path ' '/path/ {print $2}') || { echo "Failed to find Btrfs subvolume."; exit 1; }
    root_subvol_str="rootflags=subvol=$root_subvol"
else
    root_subvol_str=""
fi

# Function to update bootloader configuration
update_bootloader_config() {
    local config_path=$1
    local backup_path="${config_path}.backup"

    cp "$config_path" "$backup_path" || { echo "Failed to backup configuration file: $config_path"; exit 1; }
    sed -i "s/UUID=[a-fA-F0-9\\-]*/UUID=$root_uuid $root_subvol_str/g" "$config_path" || { echo "Failed to update configuration: $config_path"; exit 1; }
    echo "Configuration updated: $config_path"
}

# Paths to refind.conf and systemd-boot entries
refind_conf_path="/boot/EFI/refind/refind.conf"
systemd_boot_entries_path="/boot/loader/entries/*.conf"

# Update rEFInd configuration
if [ -f "$refind_conf_path" ]; then
    update_bootloader_config "$refind_conf_path"
else
    echo "rEFInd configuration file not found. Attempting installation."
    refind-install && echo "rEFInd installed successfully."
fi

# Update systemd-boot configurations
if [ -d "$(dirname "$systemd_boot_entries_path")" ]; then
    for entry in $systemd_boot_entries_path; do
        update_bootloader_config "$entry"
    done
else
    echo "systemd-boot configuration directory not found. Attempting installation."
    bootctl install && echo "systemd-boot installed successfully."
fi
