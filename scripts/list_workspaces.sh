#!/bin/bash

# Generate a menu from the workspace information
generate_menu() {
    workspaces_json=$(hyprctl workspaces -j)
    # Parse JSON and generate menu options
    echo "$workspaces_json" | jq -r '.[] | "\(.id) \"Workspace \(.id) - \(.windows) windows\" off"'
}

# Use dialog to create a selection menu, execute workspace switch immediately upon selection
select_workspace() {
    cmd=$(generate_menu)
    eval "dialog --title 'Select Workspace' --radiolist 'Choose a workspace:' 15 40 10 $cmd 2>$DIALOG_TEMP"
    
    # Read the selected workspace ID
    selected_id=$(<"$DIALOG_TEMP")
    
    # If a selection was made, dispatch the command to switch to that workspace
    if [ -n "$selected_id" ]; then
        hyprctl dispatch workspace "$selected_id"
    fi
}

# Main
select_workspace

# Cleanup
rm -f "$DIALOG_TEMP"

