#! /bin/bash

source ../global.env

SVC_USER='svc-adguard'
SVC_HOME='/srv/adguard'

sudo mkdir -p $SVC_HOME

sudo useradd -r -s /usr/sbin/nologin -d $SVC_HOME $SVC_USER
sudo chown -R $SVC_USER:$SVC_USER $SVC_HOME

sudo ufw allow from $NETMASK to any port 53 proto udp
sudo ufw allow from $NETMASK to any port 53 proto tcp

USER_UID="$(id $SVC_USER -u)" \
  USER_GID="$(id $SVC_USER -g)" \
  docker compose up -d
