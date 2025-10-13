#!/bin/bash

source ../../global.env
source ../../private.env
source .env

sudo mkdir -p $SVC_HOME/config

sudo useradd -r -s /usr/sbin/nologin -d $SVC_HOME $SVC_USER
sudo chown -R $SVC_USER:$SVC_USER $SVC_HOME

sudo ufw allow $WG_PORT/udp comment 'WireGuard VPN'

SYSCTL_FORWARD="net.ipv4.ip_forward=1"
sudo sysctl -w $SYSCTL_FORWARD
grep -q "^$SYSCTL_FORWARD" /etc/sysctl.conf || echo "$SYSCTL_FORWARD" | sudo tee -a /etc/sysctl.conf >/dev/null

UFW_RULES_DIR="/etc/ufw/user.rules.d"
sudo mkdir -p $UFW_RULES_DIR
IFACE=$(ip route | grep default | awk '{print $5}')
sed "s|__INTERFACE__|$IFACE|g" wireguard-nat.rules | sudo tee $UFW_RULES_DIR/wireguard-nat.rules >/dev/null
sudo ufw reload

USER_UID="$(id $SVC_USER -u)" \
  USER_GID="$(id $SVC_USER -g)" \
  SERVERURL="${SERVER_PUBLIC_URL:-auto}" \
  SERVERPORT="$WG_PORT" \
  PEERDNS="${SERVER_LAN_IP:-auto}" \
  INTERNAL_SUBNET="$VPN_SUBNET" \
  docker compose up -d \
  --force-recreate

# Generate split-tunnel versions of peer configs
# Wait for WireGuard to generate peer configs
until sudo [ -f "$SVC_HOME/config/peer1/peer1.conf" ]; do
  echo "Waiting for WireGuard to generate configs..."
  sleep 1
done

for peer_dir in $SVC_HOME/config/peer*; do
  if [ -d "$peer_dir" ]; then
    peer_name=$(basename "$peer_dir")
    conf_file="$peer_dir/$peer_name.conf"
    split_file="$peer_dir/${peer_name}-split.conf"
    split_png="$peer_dir/${peer_name}-split.png"
    
    if sudo [ -f "$conf_file" ] && ! sudo [ -f "$split_file" ]; then
      # Create split-tunnel version (LAN + VPN subnet only)
      sudo sed "s|AllowedIPs = 0.0.0.0/0|AllowedIPs = $NETMASK, $VPN_SUBNET|g" "$conf_file" | sudo tee "$split_file" >/dev/null
      
      # Generate QR code PNG for split-tunnel version
      sudo cat "$split_file" | sudo docker exec -i wireguard qrencode -t png -o "/config/$peer_name/${peer_name}-split.png"
      
      echo "✓ Generated split-tunnel: $peer_name"
    fi
  fi
done

