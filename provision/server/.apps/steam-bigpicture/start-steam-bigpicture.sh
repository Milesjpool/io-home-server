#!/bin/bash

USER_UID="$1"
export DISPLAY=:0

# Start X server as root (for console access)
/usr/bin/X :0 -nocursor -nolisten tcp -ac -dpi 96 -s 0 -dpms &
X_PID=$!
until xset q &>/dev/null; do sleep 0.1; done

# Start Steam Big Picture as user with preserved environment
sudo -u#$USER_UID bash -c "
  export MESA_VK_DEVICE_SELECT=0
  export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/intel_icd.x86_64.json
  
  # Bluetooth controller support
  export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket
  export XDG_RUNTIME_DIR=/run/user/$USER_UID
  
  openbox &
  sleep 0.5
  steam -bigpicture -fulldesktopres
" &
STEAM_PID=$!

cleanup() {
  echo "Cleaning up..."
  killall openbox 2>/dev/null
  kill $X_PID 2>/dev/null
}

trap cleanup EXIT INT TERM

wait $STEAM_PID