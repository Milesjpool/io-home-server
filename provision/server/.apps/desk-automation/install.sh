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
desk_enable:
  method: post
  url: 'http://desk.aesop/enabled'
desk_disable:
  method: delete
  url: 'http://desk.aesop/enabled'
EOF
fi

# Add desk sensors if sensors.yaml exists
HA_SENSORS="/srv/homeassistant/config/sensors.yaml"
if [ -f "$HA_SENSORS" ] && ! sudo grep -q "Desk Height" "$HA_SENSORS" 2>/dev/null; then
  echo "Adding Desk sensors to Home Assistant..."
  sudo tee -a "$HA_SENSORS" >/dev/null <<'EOF'
- platform: rest
  name: "Desk Height"
  resource: "http://desk.aesop/height"
  scan_interval: 30
  value_template: "{{ (value_json.height_mm / 10) | round(1) }}"
  unit_of_measurement: "cm"
- platform: rest
  name: "Desk Enabled Status"
  resource: "http://desk.aesop/enabled"
  scan_interval: 30
  value_template: "{{ 'on' if value_json.enabled == 1 else 'off' }}"
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

# Add desk enabled switch if switches.yaml exists
HA_SWITCHES="/srv/homeassistant/config/switches.yaml"
if [ -f "$HA_SWITCHES" ] && ! sudo grep -q "Desk Control" "$HA_SWITCHES" 2>/dev/null; then
  echo "Adding Desk enabled switch to Home Assistant..."
  sudo tee -a "$HA_SWITCHES" >/dev/null <<'EOF'
- platform: template
  switches:
    desk_enabled:
      friendly_name: "Desk Control"
      value_template: "{{ is_state('sensor.desk_enabled_status', 'on') }}"
      turn_on:
        - service: rest_command.desk_enable
        - service: homeassistant.update_entity
          target:
            entity_id: sensor.desk_enabled_status
      turn_off:
        - service: rest_command.desk_disable
        - service: homeassistant.update_entity
          target:
            entity_id: sensor.desk_enabled_status
EOF
fi

# Restart HA if we added anything
if [ -f "$HA_REST_COMMANDS" ] || [ -f "$HA_SENSORS" ] || [ -f "$HA_AUTOMATIONS" ] || [ -f "$HA_TEMPLATES" ] || [ -f "$HA_SWITCHES" ]; then
  docker restart home-assistant 2>/dev/null && echo "Home Assistant restarted with Desk controls"
fi
