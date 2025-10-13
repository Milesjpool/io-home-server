#! /bin/bash

source ../../global.env

SVC_USER='svc-adguard'
SVC_HOME='/srv/adguard'

sudo mkdir -p $SVC_HOME

sudo useradd -r -s /usr/sbin/nologin -d $SVC_HOME $SVC_USER
sudo chown -R $SVC_USER:$SVC_USER $SVC_HOME

# Disable systemd-resolved to free port 53 for AdGuard (idempotent)
if systemctl is-active --quiet systemd-resolved; then
  echo "Disabling systemd-resolved to free port 53"
  sudo systemctl stop systemd-resolved
  sudo systemctl disable systemd-resolved
fi

sudo ufw allow from $NETMASK to any port 53 proto udp comment 'AdGuard DNS'
sudo ufw allow from $NETMASK to any port 53 proto tcp comment 'AdGuard DNS'

USER_UID="$(id $SVC_USER -u)" \
  USER_GID="$(id $SVC_USER -g)" \
  docker compose up -d

# Configure resolv.conf to use AdGuard with fallback (idempotent)
if ! grep -q "^nameserver 127.0.0.1" /etc/resolv.conf 2>/dev/null; then
  echo "Configuring /etc/resolv.conf for AdGuard with fallback"
  sudo rm -f /etc/resolv.conf
  sudo tee /etc/resolv.conf > /dev/null <<EOF
nameserver 127.0.0.1
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF
fi
