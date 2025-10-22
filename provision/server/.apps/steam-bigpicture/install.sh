#!/bin/bash

source ../../global.env
source ../home-assistant/.env

for pkg in $(cat pkglist); do
  sudo apt-get install -y $pkg;
done

sudo usermod -aG bluetooth,input $USER

# Install Steam Big Picture service
sed "s|__USER_UID__|$(id -u)|g" steam-bigpicture.service.template | \
  sudo tee /etc/systemd/system/steam-bigpicture.service >/dev/null
sudo cp start-steam-bigpicture.sh /usr/local/bin/start-steam-bigpicture.sh
sudo chmod +x /usr/local/bin/start-steam-bigpicture.sh

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