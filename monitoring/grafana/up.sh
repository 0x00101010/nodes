#!/bin/bash
set -eu

echo "==> Starting Grafana"

# Creating shared network if necessary
NETWORK_NAME="shared_network"
if ! docker network ls | grep -q $NETWORK_NAME; then
    echo "==> Creating network: $NETWORK_NAME"
    docker network create $NETWORK_NAME
else
    echo "==> Network $NETWORK_NAME already exists"
fi

# Start Grafana
echo "==> Starting Grafana container"
docker compose up --build -d

echo "==> Done! Grafana is running at http://localhost:${GRAFANA_PORT:-3000}"