#!/bin/bash
# makeprompt.sh
# Enhanced to include a visualized tree of the directory structure

# Function to generate and display a visual tree of the directory
generate_tree() {
    echo "### Directory Structure ###"
    tree "$1"
    echo -e "\n---\n"
}

# Function to list file and its content with clear headers
list_file_and_content() {
    echo "### File Path ###"
    echo "$1"
    echo "### Contents ###"
    cat "$1"
    echo -e "\n---\n"
}

# Check if argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 [file or directory path]"
    exit 1
fi

# Check if the argument is a file or directory
if [ -d "$1" ]; then
    # It's a directory, generate tree and list all files
    generate_tree "$1"
    for file in $(find "$1" -type f); do
        list_file_and_content "$file"
    done
elif [ -f "$1" ]; then
    # It's a file, list the file with header
    list_file_and_content "$1"
else
    echo "Error: The path provided is neither a file nor a directory."
    exit 1
fi
