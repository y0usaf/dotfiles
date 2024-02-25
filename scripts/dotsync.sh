#!/bin/bash

# Git Sync Script for Default Branch Operations Only

# Define the directory and remote repository
DOTFILES_DIR="$HOME/dotfiles"
REMOTE_REPO="git@github.com-y0usaf:y0usaf/dotfiles.git"

# Default branch name (change if your default branch is different)
DEFAULT_BRANCH="main"

# Utility function for error handling
exit_with_error() {
    echo "Error: $1" >&2
    exit 1
}

# Display usage information
usage() {
    echo "Usage: $0 [push|pull]"
    echo "  push    - Sync local changes to the default branch of the remote repository."
    echo "  pull    - Sync remote changes from the default branch into the local repository."
    exit 1
}

# Verify that an argument is provided
[ $# -eq 0 ] && usage

# Change to the dotfiles directory or exit with error
cd "$DOTFILES_DIR" || exit_with_error "Directory $DOTFILES_DIR not found."

# Function to push changes
push_changes() {
    git add . || exit_with_error "Failed to add files."
    git commit -m "Sync dotfiles: $(date)" || echo "No changes to commit."
    git push origin "$DEFAULT_BRANCH" || exit_with_error "Failed to push to $DEFAULT_BRANCH."
    echo "Local changes pushed to $DEFAULT_BRANCH."
}

# Function to pull changes
pull_changes() {
    # Allow for the pull operation to proceed with unrelated histories, if necessary
    git pull --allow-unrelated-histories origin "$DEFAULT_BRANCH" || exit_with_error "Failed to pull from $DEFAULT_BRANCH."
    echo "Remote changes from $DEFAULT_BRANCH pulled."
}

# Main logic based on command-line argument
case "$1" in
    push)
        push_changes
        ;;
    pull)
        pull_changes
        ;;
    *)
        usage
        ;;
esac
