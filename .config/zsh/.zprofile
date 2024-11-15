# Start SSH agent
eval "$(ssh-agent -s)"
# Load SSH keys into SSH agent
if [ -f /home/7ktx/Tokens/id_rsa_7ktx ]; then
    ssh-add ~/Tokens/id_rsa_7ktx
fi

# Check if the hostname is 7ktx-desktop
if [ "$(hostname)" = "7ktx-desktop" ]; then
    # Set the power limit for NVIDIA GPU
    #gpupower 150 &
    # Launch Hyprland
    Hyprland
# Check if the hostname is 7ktx-laptop
elif [ "$(hostname)" = "7ktx-laptop" ]; then
    Sysup &
    Hyprland
fi
