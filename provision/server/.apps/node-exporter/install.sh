#!/bin/bash

source ../global.env

sudo ufw allow from $DOCKER_SUBNET to any port 9100 proto tcp

docker compose up -d

