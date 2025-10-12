#! /bin/bash

source ../global.env

# Allow Docker network to access Home Assistant (host network mode)
sudo ufw allow from $DOCKER_SUBNET to any port 8123 proto tcp

SVC_USER='svc-homeassistant'
SVC_HOME='/srv/homeassistant'

sudo mkdir -p $SVC_HOME/config
for file in sensors.yaml switches.yaml automations.yaml rest_commands.yaml scripts.yaml scenes.yaml templates.yaml; do
  [ ! -f "$SVC_HOME/config/$file" ] && echo "[]" | sudo tee "$SVC_HOME/config/$file" >/dev/null
done

sudo useradd -r -s /usr/sbin/nologin -d $SVC_HOME $SVC_USER
sudo usermod -aG users $SVC_USER
sudo chown -R $SVC_USER:$SVC_USER $SVC_HOME

if ! sudo grep -q "use_x_forwarded_for: true" $SVC_HOME/config/configuration.yaml 2>/dev/null; then
  sudo tee -a $SVC_HOME/config/configuration.yaml >/dev/null <<'EOF'

http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 127.0.0.1
    - ::1
EOF
fi

USER_UID="$(id $SVC_USER -u)" \
  USER_GID="$(id $SVC_USER -g)" \
  docker compose up -d --force-recreate
