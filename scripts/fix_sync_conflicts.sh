#!/bin/bash

# Check if directory path is provided as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <directory_path>"
    exit 1
fi

# Get the directory path from the command-line argument
directory_path="$1"

# Use find command to locate files containing ".sync-conflict" in the filename
# and delete them using rm command
find "$directory_path" -type f -name "*.sync-conflict*" -exec rm {} \;
