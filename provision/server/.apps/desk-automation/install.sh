#!/bin/bash

source ../../global.env
source ../home-assistant/.env

SVC_ADDR='desk.aesop'

if [ -d "$HA_PACKAGES" ]; then
  HA_DESK="$HA_PACKAGES/desk.yaml"
  sed "s|__SVC_ADDR__|$SVC_ADDR|g" desk.yaml.template | \
    sudo tee "$HA_DESK" >/dev/null
  sudo chown $HA_USER:$HA_USER "$HA_DESK"
  docker restart home-assistant
fi