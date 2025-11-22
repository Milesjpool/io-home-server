#! /bin/bash

source ../../global.env
source ../../private.env

set -euo pipefail

sudo apt-get update -y
sudo apt-get install -y fail2ban

sudo sed -e "s|__SSHD_PORT__|${SSHD_PORT:-22}|g" \
         -e "s|__NETMASK__|${NETMASK:-127.0.0.1/8}|g" \
         "jail.local.template" | sudo tee /etc/fail2ban/jail.local >/dev/null
         
sudo cp filter.d/* /etc/fail2ban/filter.d/
sudo cp "dc-iptables-multiport.conf" /etc/fail2ban/action.d/dc-iptables-multiport.conf

sudo systemctl enable fail2ban
sudo systemctl restart fail2ban

docker compose up -d --force-recreate
