#!/bin/bash

source ../../global.env
source ../home-assistant/.env

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

# Install Steam X server service
sudo cp steam-x.service /etc/systemd/system/
sudo cp steam-bigpicture.service /etc/systemd/system/

# Install Steam control service
chmod +x steam-control.py
sed "s|__INSTALL_DIR__|$(pwd)|g" steam-control.service.template | \
  sudo tee /etc/systemd/system/steam-control.service >/dev/null

sudo systemctl daemon-reload
sudo systemctl enable --now steam-control.service

# Configure firewall
sudo ufw allow from $DOCKER_SUBNET to any port 8889 proto tcp comment 'Home Assistant to Steam control'

# Add Steam control to Home Assistant
if [ -d "$HA_PACKAGES" ]; then
  HA_STEAM="$HA_PACKAGES/steam.yaml"
  sed "s|__SVC_ADDR__|127.0.0.1|g" steam.yaml.template | \
    sudo tee "$HA_STEAM" >/dev/null

  sudo chown $HA_USER:$HA_USER "$HA_STEAM"
  docker restart home-assistant
fi