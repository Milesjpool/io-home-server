#! /bin/bash

source ../global.env

SVC_USER='svc-monitoring'
SVC_HOME='/srv/monitoring'

sudo mkdir -p $SVC_HOME/{prometheus,alertmanager,grafana}

sudo useradd -r -s /usr/sbin/nologin -d $SVC_HOME $SVC_USER
sudo chown -R $SVC_USER:$SVC_USER $SVC_HOME

USER_UID="$(id $SVC_USER -u)" \
  USER_GID="$(id $SVC_USER -g)" \
  DOCKER_GATEWAY="$DOCKER_GATEWAY" \
  docker compose up -d
