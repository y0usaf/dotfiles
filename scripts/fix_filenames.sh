#!/bin/bash

# path/filename: fix_filenames.sh

# Validate input argument
if [[ -z "$1" ]]; then
    echo "Usage: $0 <path>"
    exit 1
fi

# Confirm with the user
read -p "This will modify filenames and directories under $1 to be FAT compatible. Continue? (Y/n) " response
if [[ "$response" =~ ^([nN][oO]|[nN])$ ]]; then
    echo "Operation cancelled."
    exit 0
fi

# Function to sanitize names by removing non-FAT compliant characters, preserving extension
sanitize_name() {
    local name="$1"
    # Remove non-FAT compliant characters, preserve extension
    echo "${name}" | sed -E 's/[^a-zA-Z0-9._-]//g'
}

export -f sanitize_name

# Find and rename directories first, then files to avoid issues with moved directories
find "$1" -depth -type d ! -path "$1" -exec bash -c '
    for dir; do
        new_name=$(sanitize_name "$(basename "$dir")")
        if [[ "$new_name" != "$(basename "$dir")" ]]; then
            mv -v "$dir" "$(dirname "$dir")/$new_name"
        fi
    done
' bash {} +

find "$1" -type f -exec bash -c '
    for file; do
        dir=$(dirname "$file")
        base=$(basename "$file")
        extension="${base##*.}"
        name_without_ext="${base%.*}"
        new_name=$(sanitize_name "$name_without_ext")
        if [[ "$new_name" != "$name_without_ext" ]]; then
            mv -v "$file" "$dir/$new_name.${extension}"
        fi
    done
' bash {} +

