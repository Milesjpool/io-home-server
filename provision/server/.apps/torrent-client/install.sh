#! /bin/bash

source ../../global.env
source private.env

SVC_USER='svc-torrent'
SVC_HOME='/srv/torrent-client'

sudo useradd -r -s /usr/sbin/nologin -d $SVC_HOME $SVC_USER

sudo mkdir -p $SVC_HOME/gluetun
sudo mkdir -p $SVC_HOME/qbittorrent/config
sudo mkdir -p /mnt/media/torrents

sudo chown -R $SVC_USER:$SVC_USER $SVC_HOME
sudo chown -R $SVC_USER:$SVC_USER /mnt/media/torrents

if [ -z "$OPENVPN_USER" ]; then
  read -p "Surfshark Username: " OPENVPN_USER
  echo "OPENVPN_USER='$OPENVPN_USER'" >> private.env
fi

if [ -z "$OPENVPN_PASSWORD" ]; then
  read -s -p "Surfshark Password: " OPENVPN_PASSWORD
  echo
  echo "OPENVPN_PASSWORD='$OPENVPN_PASSWORD'" >> private.env
fi

if [ -z "$SERVER_REGIONS" ]; then
  read -p "Surfshark Region (optional, press Enter to auto-select): " SERVER_REGIONS
  if [ -n "$SERVER_REGIONS" ]; then
    echo "SERVER_REGIONS='$SERVER_REGIONS'" >> private.env
  fi
fi

# Start services
USER_UID="$(id $SVC_USER -u)" \
  USER_GID="$(id $SVC_USER -g)" \
  docker compose up -d

