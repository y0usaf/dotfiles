# Start SSH agent
eval "$(ssh-agent -s)"
# Load SSH keys into SSH agent
if [ -f /home/y0usaf/Tokens/id_rsa_y0usaf ]; then
    ssh-add ~/Tokens/id_rsa_y0usaf
fi

# Check if the hostname is y0usaf-desktop
if [ "$(hostname)" = "y0usaf-desktop" ]; then
    # Set the power limit for NVIDIA GPU
    sudo nvidia-smi -pl 150
    # Launch Hyprland
    Hyprland
# Check if the hostname is y0usaf-laptop
elif [ "$(hostname)" = "y0usaf-laptop" ]; then
    Sysup &
    Hyprland
fi
