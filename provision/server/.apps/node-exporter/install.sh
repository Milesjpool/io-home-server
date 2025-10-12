#!/bin/bash

# Allow 'proxy' bridge network to access node-exporter on host
sudo ufw allow from 172.20.0.0/16 to any port 9100 proto tcp

# Node exporter runs as root to access host metrics
docker compose up -d

