#! /bin/bash

SVC_USER='svc-servarr'
SVC_HOME='/srv/servarr'

sudo mkdir -p $SVC_HOME/prowlarr
sudo mkdir -p $SVC_HOME/lidarr

sudo useradd -r -s /usr/sbin/nologin -d $SVC_HOME $SVC_USER
sudo chown -R $SVC_USER:$SVC_USER $SVC_HOME

LIDARR_IP="172.20.0.201"
QBIT_CONF="/srv/torrent-client/qbittorrent/config/qBittorrent/qBittorrent.conf"

if [ -f "$QBIT_CONF" ] && ! grep -q "$LIDARR_IP" "$QBIT_CONF"; then
  docker stop qbittorrent 2>/dev/null || true
  sudo sed -i "s|WebUI\\\\AuthSubnetWhitelist=\(.*\)|WebUI\\\\AuthSubnetWhitelist=\1,$LIDARR_IP/32|" "$QBIT_CONF"
  docker start qbittorrent 2>/dev/null || true
fi

USER_UID="$(id $SVC_USER -u)" \
  USER_GID="$(id $SVC_USER -g)" \
  LIDARR_IP="$LIDARR_IP" \
  docker compose up -d
