#!/bin/bash

# Set the source and target directories
srcdir="$HOME/dotfiles"
targetdir="$HOME"

# Loop through all files in the source directory (including subdirectories)
find "$srcdir" -type f | while read file; do
    # Get the relative path to the file
    relpath=$(realpath --relative-to="$srcdir" "$file")
    # Create the target directory if it doesn't exist
    mkdir -p "$(dirname "$targetdir/$relpath")"
    # Create the symlink
    ln -sf "$file" "$targetdir/$relpath"
done

# Check if the symlink was created successfully
if [ $? -eq 0 ]; then
    echo "Successfully linked dotfiles"
else
    echo "Error occurred while linking dotfiles"
fi
