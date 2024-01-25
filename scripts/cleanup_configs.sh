#!/bin/bash

dry_run=true

# Check for the force flag
while getopts "F" opt; do
    case $opt in
        F) dry_run=false ;;
    esac
done

# Function to extract package name from folder name and check if it's installed
is_package_installed() {
    package_name=$(echo "$1" | sed -e 's/_/-/g' | tr '[:upper:]' '[:lower:]') # Convert config folder to package name
    if pacman -Q "$package_name" &> /dev/null; then
        return 0  # Package is installed
    else
        return 1  # Package not installed
    fi
}

# Iterate through the folders in ~/.config
for folder in ~/.config/*; do
    folder_name=$(basename "$folder")
    found=false

    # Check if a corresponding package is installed
    if is_package_installed "$folder_name"; then
        found=true
    else
        echo "Debug: No installed package found for '$folder_name'"  # Debugging line
    fi

    # If no corresponding package is found, remove the folder or indicate it would be removed
    if [[ $found == false ]]; then
        if [[ $dry_run == true ]]; then
            echo "[Dry Run] Would remove: $folder_name"
        else
            echo "Removing unused folder: $folder_name"
            rm -rf "$folder"
        fi
    fi
done
