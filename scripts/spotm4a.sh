#!/bin/bash
# path/filename: spotm4a.sh
# Description: Script to download music using spotdl, organize tracks by album, and move tracks to their respective album directories if more than one track exists for an album.

# Ensure the correct number of arguments are passed
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 output_folder link"
    exit 1
fi

output_folder="$1"
link="$2"

# Download using spotdl
spotdl --format m4a --output "$output_folder" "$link"

# Temporarily store album names and corresponding file counts
declare -A album_count

# Populate album_count with album names and file counts
while IFS= read -r file; do
    album=$(ffprobe -v error -show_entries format_tags=album -of default=noprint_wrappers=1:nokey=1 "$file")
    # Skip processing if album name is empty
    if [ -z "$album" ]; then
        echo "Warning: Skipping a track without an album tag ($file)"
        continue
    fi
    # Properly increment album count
    ((album_count["$album"]++))
done < <(find "$output_folder" -type f -name "*.m4a")

# Move files to album folders only if there's more than one file for that album
while IFS= read -r file; do
    if [[ -f "$file" ]]; then
        album=$(ffprobe -v error -show_entries format_tags=album -of default=noprint_wrappers=1:nokey=1 "$file")
        # Check again for empty album to avoid errors in subshell
        if [ -z "$album" ]; then
            continue
        fi
        if [[ ${album_count["$album"]} -gt 1 ]]; then
            mkdir -p "$output_folder/$album"
            mv "$file" "$output_folder/$album/"
        fi
    fi
done < <(find "$output_folder" -type f -name "*.m4a")

