#!/bin/bash

# Define the path to the token file
TOKEN_FILE="/home/y0usaf/Tokens/GITHUB_ACCESS_TOKEN_COHERE-SAMI.txt"

# Check if the token file exists
if [ -f "$TOKEN_FILE" ]; then
    # Read the token from the file
    COHERE_TOKEN=$(<"$TOKEN_FILE")
else
    echo "Error: Token file not found" >&2
    exit 1
fi

# Output the credentials
echo "username=$COHERE_TOKEN"
echo "password=x-oauth-basic"
