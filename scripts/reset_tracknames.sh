#!/bin/bash

# Validate input argument
if [[ -z "$1" ]]; then
    echo "Usage: $0 <path>"
    exit 1
fi

directory="$1"

# Check if the directory exists
if [ ! -d "$directory" ]; then
    echo "Directory not found: $directory"
    exit 1
fi

# Find all audio files in the directory and its subdirectories
find "$directory" -type f \( -iname "*.mp3" -o -iname "*.m4a" -o -iname "*.flac" \) -print0 |
while IFS= read -r -d '' file; do
    # Get the track name using ffmpeg
    track_name=$(ffmpeg -i "$file" -f ffmetadata - 2>/dev/null | grep -i "title" | cut -d'=' -f2-)
    
    if [ -n "$track_name" ]; then
        # Sanitize the track name
        sanitized_name=$track_name
        
        # Get the file extension
        extension="${file##*.}"
        
        # Rename the file to the sanitized track name
        new_filename="$sanitized_name.$extension"
        mv -v "$file" "$(dirname "$file")/$new_filename"
    else
        echo "No track name found for $file"
    fi
done