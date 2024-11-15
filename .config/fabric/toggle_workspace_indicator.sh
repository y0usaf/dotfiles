#!/bin/bash
if pgrep -f "workspace_indicator.py" > /dev/null; then
    pkill -f "workspace_indicator.py"
else
    python3 ~/.config/fabric/workspace_indicator.py &
fi 