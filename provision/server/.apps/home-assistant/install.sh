#! /bin/bash

source ../../global.env
source .env

SVC_USER=$HA_USER
SVC_HOME=$HA_HOME

sudo useradd -r -s /usr/sbin/nologin -d $SVC_HOME $SVC_USER
sudo usermod -aG users $SVC_USER

sudo ufw allow from $DOCKER_SUBNET to any port 8123 proto tcp

sudo mkdir -p $HA_PACKAGES

sudo cp configuration.yaml "$SVC_HOME/config/configuration.yaml"
sudo chown -R $SVC_USER:$SVC_USER $SVC_HOME

USER_UID="$(id $SVC_USER -u)" \
  USER_GID="$(id $SVC_USER -g)" \
  docker compose up -d \
  --force-recreate
