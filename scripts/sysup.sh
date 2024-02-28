#!/bin/bash

# Backup Obsidian Vault
echo "Backing up Obsidian Vault..."
sudo cp -r "$HOME/Documents/Obsidian Vault" "$HOME/Documents/Obsidian Vault.bak" || { echo "Backup failed"; exit 1; }

# Empty the Trash directory
echo "Emptying the Trash directory..."
sudo rm -rf $HOME/.local/share/Trash/* || { echo "Failed to empty Trash"; exit 1; }

# Clear the cache directory
echo "Clearing the cache directory..."
sudo rm -rf $HOME/.cache/* || { echo "Failed to clear cache"; exit 1; }

# Update the system and installed packages
echo "Updating the system..."
paru -Syu --noconfirm || { echo "System update failed"; exit 1; }

# Clear pacman cache
echo "Clearing pacman cache..."
paru -Scc --noconfirm || { echo "Failed to clear pacman cache"; exit 1; }

# Remove unneeded dependencies
echo "Removing unneeded dependencies..."
while paru -Qttdq >/dev/null; do
  paru -R --noconfirm $(paru -Qttdq) || { echo "Failed to remove unneeded dependencies"; exit 1; }
done

# Link dotfiles using the specified script
echo "Linking dotfiles..."
$HOME/dotfiles/scripts/dotlink.sh || { echo "Dotfiles linking failed"; exit 1; }

# Save the list of installed packages
echo "Saving the list of installed packages..."
paru -Qq > "$HOME/dotfiles/pkglist-$(hostname).txt" || { echo "Failed to save the list of installed packages"; exit 1; }

echo "All tasks completed successfully"
