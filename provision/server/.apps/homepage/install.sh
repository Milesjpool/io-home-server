#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_NAME="homepage"

echo "Installing ${APP_NAME}..."

# Create required directories
sudo mkdir -p /srv/${APP_NAME}

# Set ownership
sudo chown -R "${USER}:${USER}" /srv/${APP_NAME}

# Start the service
docker compose -f "${SCRIPT_DIR}/docker-compose.yml" up -d

echo "${APP_NAME} installed and started successfully!"
echo "The homepage will be accessible as the default route on your server."