#!/bin/bash

# Set the credential helper
git config --global credential.helper "$0"  # "$0" refers to the script itself

# Output the credentials
echo "username=$GIT_TOKEN"
echo "password=x-oauth-basic"
