#!/bin/bash

cd ~/dotfiles

# Check if the .git directory exists, indicating a Git repository is initialized
if [ ! -d .git ]; then
  # If not, initialize a new Git repository
  git init
  # Add the remote repository
  git remote add origin https://github.com/y0usaf/dotfiles
fi

# Adding any new files
git add .

# Committing changes
git commit -m "Automated commit of dotfiles"

# Pushing changes to GitHub
git push origin main
