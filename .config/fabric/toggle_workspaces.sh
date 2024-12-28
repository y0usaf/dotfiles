#!/bin/bash
if pgrep -f "workspaces.py" > /dev/null; then
    pkill -f "workspaces.py"
else
    python3 ~/.config/fabric/workspaces.py &
fi 