#!/bin/bash

source ../../global.env
source ../home-assistant/.env

chmod +x gdm-control.py

sudo ufw allow from $DOCKER_SUBNET to any port 8888 proto tcp

sed "s|__INSTALL_DIR__|$(pwd)|g" gdm-control.service.template | \
  sudo tee /etc/systemd/system/gdm-control.service >/dev/null

sudo systemctl daemon-reload
sudo systemctl enable --now gdm-control.service

SVC_ADDR=127.0.0.1

if [ -d "$HA_PACKAGES" ]; then
  HA_DESKTOP="$HA_PACKAGES/desktop.yaml"
  sed "s|__SVC_ADDR__|$SVC_ADDR|g" desktop.yaml.template | \
    sudo tee "$HA_DESKTOP" >/dev/null

  sudo chown $HA_USER:$HA_USER "$HA_DESKTOP"
  docker restart home-assistant
fi
