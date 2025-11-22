#! /bin/bash

source ../../../private.env

set -euo pipefail

sudo apt-get update -y
sudo apt-get install -y fail2ban

sudo sed "s|__SSHD_PORT__|${SSHD_PORT:-22}|g" "jail.local.template" | sudo tee /etc/fail2ban/jail.local >/dev/null
sudo cp filter.d/* /etc/fail2ban/filter.d/
sudo cp "dc-iptables-multiport.conf" /etc/fail2ban/action.d/dc-iptables-multiport.conf

sudo systemctl enable fail2ban
sudo systemctl restart fail2ban
