# Check if the hostname is y0usaf-desktop
if [ "$(hostname)" = "y0usaf-desktop" ]; then
    # Set the power limit for NVIDIA GPU
    sudo nvidia-smi -pl 200 &

    # Launch Hyprland
    Hyprland

# Check if the hostname is y0usaf-laptop
elif [ "$(hostname)" = "y0usaf-laptop" ]; then
    Sysup &
    Hyprland
fi
