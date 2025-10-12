#!/bin/bash

# Add Home Assistant integration if HA is installed
HA_REST_COMMANDS="/srv/homeassistant/config/rest_commands.yaml"
HA_AUTOMATIONS="/srv/homeassistant/config/automations.yaml"

if [ -f "$HA_REST_COMMANDS" ] && ! sudo grep -q "desk_stand:" "$HA_REST_COMMANDS" 2>/dev/null; then
  echo "Adding Desk controls to Home Assistant..."
  sudo tee -a "$HA_REST_COMMANDS" >/dev/null <<'EOF'
desk_preset:
  method: post
  url: "http://desk.aesop/height/preset/{{ desk_preset }}"
desk_sit:
  method: post
  url: 'http://desk.aesop/height/preset/sit'
desk_stand:
  method: post
  url: 'http://desk.aesop/height/preset/stand'
desk_stop: 
  method: delete
  url: 'http://desk.aesop/height'
EOF
fi

# Add desk height sensor if sensors.yaml exists
HA_SENSORS="/srv/homeassistant/config/sensors.yaml"
if [ -f "$HA_SENSORS" ] && ! sudo grep -q "Desk Height" "$HA_SENSORS" 2>/dev/null; then
  echo "Adding Desk height sensor to Home Assistant..."
  sudo tee -a "$HA_SENSORS" >/dev/null <<'EOF'
- platform: rest
  name: "Desk Height"
  resource: "http://desk.aesop/height"
  scan_interval: 30
  value_template: "{{ (value_json.height_mm / 10) | round(1) }}"
  unit_of_measurement: "cm"
EOF
fi

# Add desk buttons if templates.yaml exists
HA_TEMPLATES="/srv/homeassistant/config/templates.yaml"
if [ -f "$HA_TEMPLATES" ] && ! sudo grep -q "Desk: Sit" "$HA_TEMPLATES" 2>/dev/null; then
  echo "Adding Desk buttons to Home Assistant..."
  sudo tee -a "$HA_TEMPLATES" >/dev/null <<'EOF'
- button:
    - name: "Desk: Sit"
      icon: mdi:seat-passenger
      press:
        - service: rest_command.desk_sit
    - name: "Desk: Stand"
      icon: mdi:human-male
      press:
        - service: rest_command.desk_stand
    - name: "Desk: Stop"
      icon: mdi:minus-circle-outline
      press:
        - service: rest_command.desk_stop
EOF
fi

# Add desk automation if automations.yaml exists
if [ -f "$HA_AUTOMATIONS" ] && ! sudo grep -q "Raise desk on weekdays" "$HA_AUTOMATIONS" 2>/dev/null; then
  echo "Adding Desk automation to Home Assistant..."
  sudo tee -a "$HA_AUTOMATIONS" >/dev/null <<'EOF'
- id: desk_raise_weekday
  alias: "Raise desk on weekdays"
  trigger:
    - platform: time
      at: "14:00:00"
  condition:
    - condition: time
      weekday:
        - mon
        - tue
        - wed
        - thu
        - fri
  action:
    - service: rest_command.desk_stand
EOF
fi

# Restart HA if we added anything
if [ -f "$HA_REST_COMMANDS" ] || [ -f "$HA_SENSORS" ] || [ -f "$HA_AUTOMATIONS" ] || [ -f "$HA_TEMPLATES" ]; then
  docker restart home-assistant 2>/dev/null && echo "Home Assistant restarted with Desk controls"
fi

echo "Desk controls added: sit/stand/stop buttons, height sensor, and 2pm weekday automation"
