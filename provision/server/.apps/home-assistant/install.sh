#! /bin/bash

source ../global.env

SVC_USER='svc-homeassistant'
SVC_HOME='/srv/homeassistant'

sudo mkdir -p $SVC_HOME

sudo useradd -r -s /usr/sbin/nologin -d $SVC_HOME $SVC_USER
sudo chown -R $SVC_USER:$SVC_USER $SVC_HOME

sudo usermod -aG users $SVC_USER

# Configure trusted proxy for Caddy reverse proxy
if ! sudo grep -q "$DOCKER_SUBNET" $SVC_HOME/config/configuration.yaml 2>/dev/null; then
  sudo tee -a $SVC_HOME/config/configuration.yaml >/dev/null <<EOF

# Trust Caddy reverse proxy
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - $DOCKER_SUBNET
EOF
fi

USER_UID="$(id $SVC_USER -u)" \
  USER_GID="$(id $SVC_USER -g)" \
  docker compose up -d --force-recreate
