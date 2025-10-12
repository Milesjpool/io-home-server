#!/bin/bash

# Load Docker network config from global config
source ../global.env

# Make script executable
chmod +x gdm-control.py

# Allow Docker network to access desktop control service
sudo ufw allow from $DOCKER_SUBNET to any port 8888 proto tcp

# Create systemd service
sudo tee /etc/systemd/system/gdm-control.service >/dev/null <<EOF
[Unit]
Description=GDM Control HTTP Service
After=network.target

[Service]
Type=simple
ExecStart=$(pwd)/gdm-control.py
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now gdm-control.service

echo "GDM control service installed"

# Add Home Assistant integration if HA is installed and config doesn't exist
HA_CONFIG="/srv/homeassistant/config/configuration.yaml"
if [ -f "$HA_CONFIG" ] && ! sudo grep -q "desktop_start:" "$HA_CONFIG" 2>/dev/null; then
  echo "Adding Desktop control to Home Assistant..."
  sudo tee -a "$HA_CONFIG" >/dev/null <<EOF

# Desktop control commands
rest_command:
  desktop_start:
    url: "http://$DOCKER_GATEWAY:8888/start"
  desktop_stop:
    url: "http://$DOCKER_GATEWAY:8888/stop"

# Desktop status sensor
sensor:
  - platform: rest
    name: "Io Desktop Status"
    resource: "http://$DOCKER_GATEWAY:8888/status"
    scan_interval: 5
    value_template: "{{ value }}"

# Desktop control switch
switch:
  - platform: template
    switches:
      desktop:
        friendly_name: "Io Desktop"
        value_template: "{{ states('sensor.desktop_status') == 'active' }}"
        turn_on:
          service: rest_command.desktop_start
        turn_off:
          service: rest_command.desktop_stop
EOF
  docker restart home-assistant 2>/dev/null && echo "Home Assistant restarted with Desktop switch"
fi

echo "Usage:"
echo "  curl http://localhost:8888/start  - Start GDM"
echo "  curl http://localhost:8888/stop   - Stop GDM"
echo "  curl http://localhost:8888/status - Check GDM status"
echo "  Or use Home Assistant switch.desktop entity"
