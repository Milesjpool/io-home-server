#!/bin/bash

for pkg in $(cat pkglist); do
  sudo apt-get install -y $pkg;
done

# Configure X11 permissions for non-root access (idempotent)
if ! grep -q "allowed_users=anybody" /etc/X11/Xwrapper.config 2>/dev/null; then
  echo "allowed_users=anybody" | sudo tee /etc/X11/Xwrapper.config
fi
if ! grep -q "needs_root_rights=no" /etc/X11/Xwrapper.config 2>/dev/null; then
  echo "needs_root_rights=no" | sudo tee -a /etc/X11/Xwrapper.config
fi

# Install Steam X server service (idempotent)
sudo cp steam-x.service /etc/systemd/system/
sudo cp steam-bigpicture.service /etc/systemd/system/
sudo systemctl daemon-reload