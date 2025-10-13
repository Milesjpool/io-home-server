#!/bin/bash

source ../../global.env
source ../../private.env
source .env

sudo mkdir -p $SVC_HOME/config

sudo useradd -r -s /usr/sbin/nologin -d $SVC_HOME $SVC_USER
sudo chown -R $SVC_USER:$SVC_USER $SVC_HOME

sudo ufw allow $WG_PORT/udp comment 'WireGuard VPN'

SYSCTL_FORWARD="net.ipv4.ip_forward=1"
sudo sysctl -w $SYSCTL_FORWARD
grep -q "^$SYSCTL_FORWARD" /etc/sysctl.conf || echo "$SYSCTL_FORWARD" | sudo tee -a /etc/sysctl.conf >/dev/null

USER_UID="$(id $SVC_USER -u)" \
  USER_GID="$(id $SVC_USER -g)" \
  SERVERURL="${SERVER_PUBLIC_URL:-auto}" \
  SERVERPORT="$WG_PORT" \
  PEERDNS="${SERVER_LAN_IP:-auto}" \
  INTERNAL_SUBNET="$VPN_SUBNET" \
  docker compose up -d \
  --force-recreate

