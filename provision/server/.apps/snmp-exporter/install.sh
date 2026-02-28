#!/bin/bash

source ../../global.env
source ../../private.env

set -euo pipefail

# Check if snmp.yml exists
if [ ! -f "snmp.yml" ]; then
    echo "ERROR: snmp.yml not found!"
    echo "Please generate snmp.yml first using the snmp_exporter generator."
    echo "See README.md for instructions."
    exit 1
fi

# Allow Prometheus to access snmp-exporter
sudo ufw allow from $DOCKER_SUBNET to any port 9116 proto tcp comment 'Prometheus to snmp-exporter' || true

docker compose up -d






