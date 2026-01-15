#! /bin/bash

source ../../global.env
source ../../private.env
source private.env

SVC_USER='svc-torrent'
SVC_HOME='/srv/torrent-client'

sudo useradd -r -s /usr/sbin/nologin -d $SVC_HOME $SVC_USER

sudo mkdir -p $SVC_HOME/gluetun
sudo mkdir -p $SVC_HOME/qbittorrent/config/logs
sudo mkdir -p $SVC_HOME/qbittorrent/data/incomplete
sudo mkdir -p /mnt/torrents

sudo chown -R $SVC_USER:$SVC_USER $SVC_HOME

if sudo [ -f "$NAS_CRED_FILE" ] && [ -n "$NAS_HOST" ]; then
  TORRENTS_FSTAB="//$NAS_HOST/media/downloads /mnt/torrents cifs credentials=$NAS_CRED_FILE,vers=3.0,uid=$SVC_USER,gid=$SVC_USER 0 0"
  if ! grep -q "/mnt/torrents" /etc/fstab; then
    echo "$TORRENTS_FSTAB" | sudo tee -a /etc/fstab > /dev/null
  fi
  sudo mount /mnt/torrents
fi

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

USER_UID="$(id $SVC_USER -u)" \
  USER_GID="$(id $SVC_USER -g)" \
  docker compose up -d --force-recreate
