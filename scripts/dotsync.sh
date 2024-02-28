#!/bin/bash
# Git Sync Script for Aggressive Default Branch Operations

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
    echo "  push    - Force local changes to override the default branch of the remote repository."
    echo "  pull    - Force remote changes to override local changes from the default branch."
    exit 1
}

# Verify that an argument is provided
[ $# -eq 0 ] && usage

# Change to the dotfiles directory or exit with error
cd "$DOTFILES_DIR" || exit_with_error "Directory $DOTFILES_DIR not found."

# Function to forcefully push changes, preferring local changes
push_changes() {
    git add . || exit_with_error "Failed to add files."
    git commit -m "Sync dotfiles: $(date)" || echo "No changes to commit."
    # Force push to overwrite remote changes with local changes
    git push --force origin "$DEFAULT_BRANCH" || exit_with_error "Failed to force-push to $DEFAULT_BRANCH."
    echo "Local changes forcefully pushed to $DEFAULT_BRANCH."
}

# Function to forcefully pull changes, preferring remote changes
pull_changes() {
    # Reset local changes to match remote repository state
    git fetch origin "$DEFAULT_BRANCH" || exit_with_error "Failed to fetch from $DEFAULT_BRANCH."
    git reset --hard origin/"$DEFAULT_BRANCH" || exit_with_error "Failed to hard reset to $DEFAULT_BRANCH."
    echo "Local state forcefully reset to match remote $DEFAULT_BRANCH."
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
