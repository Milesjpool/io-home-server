#!/bin/bash

USER_UID="$1"
export DISPLAY=:0
export XDG_RUNTIME_DIR=/run/user/$USER_UID

# Start X server as root (for console access)
/usr/bin/X :0 -nocursor -nolisten tcp -ac &
until xset q &>/dev/null; do sleep 0.1; done

# Start Steam Big Picture as user with preserved environment
sudo -u#$USER_UID -E bash -c "
  openbox &
  sleep 0.5
  steam -bigpicture -fulldesktopres
"