#! /bin/bash

source ../global.env

SVC_USER='svc-adguard'
SVC_HOME='/srv/adguard'

sudo mkdir -p $SVC_HOME

sudo useradd -r -s /usr/sbin/nologin -d $SVC_HOME $SVC_USER
sudo chown -R $SVC_USER:$SVC_USER $SVC_HOME

SERVER_IP=$(hostname -I | awk '{print $1}')
sudo ufw allow from $NETMASK to $SERVER_IP port 53 proto udp
sudo ufw allow from $NETMASK to $SERVER_IP port 53 proto tcp

DNS_BIND_IP="$SERVER_IP" \
  USER_UID="$(id $SVC_USER -u)" \
  USER_GID="$(id $SVC_USER -g)" \
  docker compose up -d
