#!/bin/bash

SVC_HOME='/srv/portainer'

sudo mkdir -p $SVC_HOME

# Portainer needs access to docker socket, runs as root
docker compose up -d

