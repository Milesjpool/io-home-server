#!/bin/bash

source ../../global.env
source ../home-assistant/.env
source private.env

for pkg in $(cat pkglist); do
  sudo apt-get install -y $pkg;
done

sudo usermod -aG bluetooth,input,render,audio,video $USER

if ! grep -q "kernel.unprivileged_userns_clone=1" /etc/sysctl.conf; then
  echo 'kernel.unprivileged_userns_clone=1' | sudo tee -a /etc/sysctl.conf
fi
sudo sysctl -p

read -p "Controller MAC [$CONTROLLER_MAC]: " input
CONTROLLER_MAC="${input:-$CONTROLLER_MAC}"

cat > private.env <<EOF
CONTROLLER_MAC='$CONTROLLER_MAC'
EOF

# =============================================================================
# STEAM BIG PICTURE SERVICE
# =============================================================================

sed "s|__USER_UID__|$(id -u)|g" steam-bigpicture.service.template | \
  sed "s|__CONTROLLER_MAC__|$CONTROLLER_MAC|g" | \
  sudo tee /etc/systemd/system/steam-bigpicture.service >/dev/null
sudo cp start-steam-bigpicture.sh /usr/local/bin/start-steam-bigpicture.sh
sudo chmod +x /usr/local/bin/start-steam-bigpicture.sh

# =============================================================================
# BLUETOOTH CONTROL
# =============================================================================
sed "s|__CONTROLLER_MAC__|$CONTROLLER_MAC|g" bluetooth.rules.template | \
  sudo tee /etc/udev/rules.d/99-steam-bluetooth.rules >/dev/null
sudo udevadm control --reload-rules
sudo udevadm trigger

# =============================================================================
# HOME ASSISTANT CONTROL
# =============================================================================
chmod +x steam-control.py
sed "s|__INSTALL_DIR__|$(pwd)|g" steam-control.service.template | \
  sudo tee /etc/systemd/system/steam-control.service >/dev/null

sudo systemctl daemon-reload
sudo systemctl enable --now steam-control.service

sudo ufw allow from $DOCKER_SUBNET to any port 8889 proto tcp comment 'Home Assistant to Steam control'

if [ -d "$HA_PACKAGES" ]; then
  HA_STEAM="$HA_PACKAGES/steam.yaml"
  sed "s|__SVC_ADDR__|127.0.0.1|g" steam-control.yaml.template | \
    sudo tee "$HA_STEAM" >/dev/null

  sudo chown $HA_USER:$HA_USER "$HA_STEAM"
  docker restart home-assistant
fi