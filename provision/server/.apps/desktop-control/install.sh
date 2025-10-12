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

# Add Home Assistant integration if HA is installed
HA_CONFIG="/srv/homeassistant/config/configuration.yaml"
HA_REST_COMMANDS="/srv/homeassistant/config/rest_commands.yaml"
HA_SENSORS="/srv/homeassistant/config/sensors.yaml"
HA_SWITCHES="/srv/homeassistant/config/switches.yaml"

# Add desktop rest_commands if not present
if [ -f "$HA_REST_COMMANDS" ] && ! sudo grep -q "desktop_start:" "$HA_REST_COMMANDS" 2>/dev/null; then
  echo "Adding Desktop controls to Home Assistant..."
  sudo tee -a "$HA_REST_COMMANDS" >/dev/null <<EOF
desktop_start:
  method: get
  url: "http://$DOCKER_GATEWAY:8888/start"
desktop_stop:
  method: get
  url: "http://$DOCKER_GATEWAY:8888/stop"
EOF
fi

# Add desktop sensor if sensors.yaml exists
if [ -f "$HA_SENSORS" ] && ! sudo grep -q "Io Desktop Status" "$HA_SENSORS" 2>/dev/null; then
  echo "Adding Desktop sensor to Home Assistant..."
  sudo tee -a "$HA_SENSORS" >/dev/null <<EOF
- platform: rest
  name: "Io Desktop Status"
  resource: "http://$DOCKER_GATEWAY:8888/status"
  scan_interval: 5
  value_template: "{{ value }}"
EOF
  docker restart home-assistant 2>/dev/null && echo "Home Assistant restarted with Desktop integration"
fi

# Add desktop switch if switches.yaml exists
if [ -f "$HA_SWITCHES" ] && ! sudo grep -q "friendly_name: \"Io Desktop\"" "$HA_SWITCHES" 2>/dev/null; then
  echo "Adding Desktop switch to Home Assistant..."
  sudo tee -a "$HA_SWITCHES" >/dev/null <<EOF
- platform: template
  switches:
    desktop:
      friendly_name: "Io Desktop"
      value_template: "{{ states('sensor.io_desktop_status') == 'active' }}"
      turn_on:
        service: rest_command.desktop_start
      turn_off:
        service: rest_command.desktop_stop
EOF
  docker restart home-assistant 2>/dev/null && echo "Home Assistant restarted with Desktop integration"
fi

echo "Usage:"
echo "  curl http://localhost:8888/start  - Start GDM"
echo "  curl http://localhost:8888/stop   - Stop GDM"
echo "  curl http://localhost:8888/status - Check GDM status"
echo "  Or use Home Assistant switch.desktop entity"
