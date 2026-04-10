#! /bin/bash

SVC_USER='svc-slskd'
SVC_HOME='/srv/slskd'

sudo mkdir -p $SVC_HOME/config

sudo useradd -r -s /usr/sbin/nologin -d $SVC_HOME $SVC_USER
sudo chown -R $SVC_USER:$SVC_USER $SVC_HOME

sudo usermod -aG media $SVC_USER

USER_UID="$(id $SVC_USER -u)" \
  USER_GID="$(id $SVC_USER -g)" \
  docker compose up -d
