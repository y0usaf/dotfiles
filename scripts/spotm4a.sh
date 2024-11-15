#!/bin/bash
# Description: Optimized script to download music using spotdl

# Enable parallel job control
set -m

# Check if spotdl is installed
command -v spotdl &> /dev/null || {
    echo "Error: spotdl is not installed. Install with: pip install spotdl" >&2
    exit 1
}

# Validate arguments
[[ $# -ne 2 ]] && {
    echo "Usage: $0 output_folder spotify_link" >&2
    echo "Example: $0 ~/Music \"https://open.spotify.com/track/...\"" >&2
    exit 1
}

output_folder="$1"
# Clean URL and properly quote it
link="${2%%\?*}"

# Validate the Spotify link format (basic check)
[[ "$link" =~ ^https://open\.spotify\.com/ ]] || {
    echo "Error: Invalid Spotify link format" >&2
    echo "Link should start with 'https://open.spotify.com/'" >&2
    exit 1
}

# Create output directory if needed (with better error handling)
mkdir -p "$output_folder" 2>/dev/null || {
    echo "Error: Failed to create output directory" >&2
    exit 1
}

echo "Starting download..."

# Run spotdl with correct argument order
cd "$output_folder" && spotdl \
    --format m4a \
    --output "{artist}_{title}" \
    --threads 8 \
    --restrict \
    --sponsor-block \
    download "$link" || {
    echo "Error: Download failed" >&2
    exit 1
}

echo "Download completed successfully!"