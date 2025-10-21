#!/bin/bash

# Get user from parameter
USER="$1"
if [ -z "$USER" ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

# Get user ID
UID=$(id -u "$USER")
if [ -z "$UID" ]; then
    echo "User $USER not found"
    exit 1
fi

# Set up environment
export DISPLAY=:0
export XDG_RUNTIME_DIR="/run/user/$UID"

# Start X server as root, then switch to user for Steam
/usr/bin/X :0 -nocursor -nolisten tcp -ac &
X_PID=$!

# Wait for X server to be ready
until xset q &>/dev/null; do sleep 0.1; done

# Switch to user and start Steam
exec su - "$USER" -c "export DISPLAY=:0 && export XDG_RUNTIME_DIR=/run/user/$UID && /snap/bin/steam -bigpicture -steamos"