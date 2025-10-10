#! /bin/bash

SVC_USER='svc-revproxy'
SVC_HOME='/srv/revproxy'

sudo mkdir -p $SVC_HOME

sudo useradd -r -s /usr/sbin/nologin -d $SVC_HOME $SVC_USER
sudo chown -R $SVC_USER:$SVC_USER $SVC_HOME

USER_UID="$(id $SVC_USER -u)" \
  USER_GID="$(id $SVC_USER -g)" \
  docker compose up -d \
  --force-recreate

