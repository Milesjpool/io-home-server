#! /bin/bash

source ../../global.env
source ../home-assistant/.env

SVC_USER='svc-revproxy'
SVC_HOME='/srv/revproxy'

sudo mkdir -p $SVC_HOME

sudo useradd -r -s /usr/sbin/nologin -d $SVC_HOME $SVC_USER
sudo chown -R $SVC_USER:$SVC_USER $SVC_HOME

sudo ufw allow from $NETMASK to any port 80 proto tcp comment 'Caddy HTTP (LAN)'
sudo ufw allow from $NETMASK to any port 443 proto tcp comment 'Caddy HTTPS (LAN)'
sudo ufw allow 443/tcp comment 'Caddy HTTPS (public)'
sudo ufw allow from $DOCKER_SUBNET to any port 2019 proto tcp comment 'Docker network to Caddy metrics'

if [ -d "$HA_PACKAGES" ]; then
  HA_REVPROXY="$HA_PACKAGES/reverse_proxy.yaml"
  sed "s|__DOCKER_SUBNET__|$DOCKER_SUBNET|g" reverse_proxy.yaml.template | \
    sudo tee "$HA_REVPROXY" >/dev/null
  sudo chown $HA_USER:$HA_USER "$HA_REVPROXY"
  docker restart home-assistant
fi

USER_UID="$(id $SVC_USER -u)" \
  USER_GID="$(id $SVC_USER -g)" \
  DOCKER_SUBNET="$DOCKER_SUBNET" \
  DOCKER_GATEWAY="$DOCKER_GATEWAY" \
  docker compose up -d \
  --force-recreate

