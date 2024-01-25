#!/bin/bash

# Define the directory and remote repository
DOTFILES_DIR="$HOME/dotfiles"
REMOTE_REPO="git@github.com-y0usaf:y0usaf/dotfiles.git"

# Change to the dotfiles directory
cd "$DOTFILES_DIR" || exit 1

# Function to setup git and sync for the first time
setup_git_and_sync() {
    git init
    git remote add origin "$REMOTE_REPO"
    git checkout -b main
    git add .
    git commit -m "Initial commit"
    git push -u origin main
}

# Function to sync existing repo
sync_existing_repo() {
    # Get the current branch
    BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null)

    # If git branch doesn't return a value, assume it's 'main'
    if [ -z "$BRANCH" ]; then
        BRANCH="main"
    fi

    # Set pull to merge (not rebase)
    git config pull.rebase false

    # Pull changes from the remote repository, merging them into your local branch
    git pull origin "$BRANCH"

    # Sync files
    git add .
    git commit -m "Sync dotfiles: $(date)"
    git push origin "$BRANCH"
}

# Check if .git directory exists to determine if repo is initialized
if [ ! -d ".git" ]; then
    setup_git_and_sync
else
    sync_existing_repo
fi
