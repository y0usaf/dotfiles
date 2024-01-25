#!/bin/bash

# Define the directory to watch
DIRECTORY="$HOME/dotfiles/.config/ags"

# Add a starting message to the console
echo "Starting monitoring of $DIRECTORY at $(date)"

# Loop indefinitely
while true; do
    # Wait for any change in the directory and echo the event to console
    echo "Waiting for changes..."
    inotifywait -e modify,create,delete -r "$DIRECTORY"

    # Echo the execution of commands to console
    echo "Detected change at $(date), executing commands..."

    # Commands to execute
    exec ags -q
    exec ags

    # Echo completion of commands to console
    echo "Commands executed at $(date)"
done
