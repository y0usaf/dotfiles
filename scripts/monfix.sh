#!/usr/bin/env bash

# Ensure dialog is available
if ! command -v dialog &> /dev/null; then
    echo "dialog is required. Please install it first."
    exit 1
fi

trap 'clear; hyprctl keyword monitor "DP-1, highres@highrr,0x0,1"; exit' INT TERM

while true; do
    dialog --infobox "Disabling DP-1..." 3 30
    hyprctl keyword monitor "DP-1, disable"
    
    dialog --infobox "Waiting 7 seconds..." 3 30
    sleep 7
    
    dialog --infobox "Re-enabling DP-1..." 3 30
    hyprctl keyword monitor "DP-1, highres@highrr,0x0,1"
    
    if dialog --timeout 3 \
              --title "Monitor Fix" \
              --yes-label "FIXED" \
              --no-label "Wait..." \
              --yesno "\nClick FIXED if monitor is working\n(Auto-continues in 3s)" 8 40; then
        clear
        exit 0
    fi
done