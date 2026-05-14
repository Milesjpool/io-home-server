#! /bin/bash

SVC_USER='svc-servarr'
SVC_HOME='/srv/servarr'

sudo mkdir -p $SVC_HOME/prowlarr
sudo mkdir -p $SVC_HOME/lidarr
sudo mkdir -p $SVC_HOME/radarr

sudo useradd -r -s /usr/sbin/nologin -d $SVC_HOME $SVC_USER
sudo chown -R $SVC_USER:$SVC_USER $SVC_HOME

LIDARR_IP="172.20.0.201"
RADARR_IP="172.20.0.202"

USER_UID="$(id $SVC_USER -u)" \
  USER_GID="$(id $SVC_USER -g)" \
  LIDARR_IP="$LIDARR_IP" \
  RADARR_IP="$RADARR_IP" \
  docker compose up -d
