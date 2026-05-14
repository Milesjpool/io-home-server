#! /bin/bash

SVC_USER='svc-audiobookshelf'
SVC_HOME='/srv/audiobookshelf'

sudo mkdir -p "$SVC_HOME/config" "$SVC_HOME/metadata"

if ! getent passwd "$SVC_USER" >/dev/null; then
  sudo useradd -r -s /usr/sbin/nologin -d "$SVC_HOME" "$SVC_USER"
fi
sudo chown -R "$SVC_USER:$SVC_USER" "$SVC_HOME"

sudo usermod -aG media "$SVC_USER"

USER_UID="$(id "$SVC_USER" -u)" \
  USER_GID="$(id "$SVC_USER" -g)" \
  docker compose up -d
