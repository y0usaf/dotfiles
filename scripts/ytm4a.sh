#!/bin/bash
# path/filename: ytm4a.sh
# Description: Script to download audio using yt-dlp, format output in m4a, and handle errors gracefully.

# Ensure the correct number of arguments are passed
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 output_folder link"
    exit 1
fi

output_folder="$1"
# Use "$2" directly to properly handle arguments containing spaces or special characters
link="$2"

# Download using yt-dlp with specified output format and directory
if yt-dlp --extract-audio --audio-format m4a -o "${output_folder}/%(title)s.%(ext)s" "$link"; then
    echo "Download and extraction successful."
else
    echo "Error: yt-dlp failed to download or extract audio."
    exit 2
fi

