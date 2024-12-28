#!/bin/bash

# Check if ffprobe is installed
if ! command -v ffprobe &> /dev/null
then
    echo "ffprobe could not be found. Please install it."
    exit
fi

# Parse command line arguments
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -a|--album)
        report_type="album"
        shift
        ;;
        -g|--genre)
        report_type="genre"
        shift
        ;;
        -y|--year)
        report_type="year"
        shift
        ;;
        *)
        echo "Unknown option: $1"
        exit
        ;;
    esac
done

# Generate the report
find ~/Music -type f -name "*.mp3" -exec ffprobe -v quiet -print_format json -show_format {} \; | jq -r ".format.tags.$report_type" | grep -v "null" | sort | uniq -c | sort -nr