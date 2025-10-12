#!/bin/bash

# Load Docker network config
source ../global.env

# Allow 'proxy' bridge network to access node-exporter on host
sudo ufw allow from $DOCKER_SUBNET to any port 9100 proto tcp

# Node exporter runs as root to access host metrics
docker compose up -d

