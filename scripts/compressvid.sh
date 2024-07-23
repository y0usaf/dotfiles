#!/bin/bash

# Desired target size in MB (adjustable)
target_size_mb=50

# Function to compress video
compress_video() {
  local file=$1
  local target_size_mb=$2

  # Get the duration of the video in seconds (as a floating-point number)
  duration=$(ffmpeg -i "$file" 2>&1 | grep "Duration" | awk '{print $2}' | tr -d , | awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')

  # Calculate the bitrate in kbps, adding a safety margin
  target_size_kb=$((target_size_mb * 1024))
  # Consider muxing overhead (5% safety margin)
  target_size_kb_with_margin=$(echo "$target_size_kb * 0.95" | bc)
  bitrate=$(echo "scale=2; ($target_size_kb_with_margin * 8) / $duration" | bc)

  # Compress the file with ffmpeg using NVIDIA GPU and make it iPhone compatible
  ffmpeg -hwaccel nvdec -i "$file" -c:v h264_nvenc -profile:v main -level 3.1 -b:v ${bitrate}k -c:a aac -b:a 128k -movflags +faststart -y "compressed_${file##*/}"
}

# Check if the script was run with parameters
if [ $# -eq 2 ]; then
  compress_video "$1" "$2"
else
  # Loop through all the .mp4 files in the directory if no parameters were passed
  for file in *.mp4; do
    compress_video "$file" $target_size_mb
  done
fi
