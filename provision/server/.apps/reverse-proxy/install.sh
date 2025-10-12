#! /bin/bash

source ../global.env

SVC_USER='svc-revproxy'
SVC_HOME='/srv/revproxy'

sudo mkdir -p $SVC_HOME

sudo useradd -r -s /usr/sbin/nologin -d $SVC_HOME $SVC_USER
sudo chown -R $SVC_USER:$SVC_USER $SVC_HOME

sudo ufw allow from $NETMASK to any port 80 proto tcp
sudo ufw allow from $NETMASK to any port 443 proto tcp

USER_UID="$(id $SVC_USER -u)" \
  USER_GID="$(id $SVC_USER -g)" \
  DOCKER_SUBNET="$DOCKER_SUBNET" \
  DOCKER_GATEWAY="$DOCKER_GATEWAY" \
  docker compose up -d \
  --force-recreate

