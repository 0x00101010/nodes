#!/bin/bash
set -eu

echo "==> Starting Monitoring Stack (Prometheus, Node Exporter, cAdvisor, Grafana)"

# Creating shared network if necessary
NETWORK_NAME="shared_network"
if ! docker network ls | grep -q $NETWORK_NAME; then
    echo "==> Creating network: $NETWORK_NAME"
    docker network create $NETWORK_NAME
else
    echo "==> Network $NETWORK_NAME already exists"
fi

# Start all services
echo "==> Starting monitoring services"
docker compose up --build -d

echo ""
echo "==> Done! Services are running:"
echo "  - Grafana:       http://localhost:3000"
echo "  - Prometheus:    http://localhost:9190"
echo "  - Node Exporter: http://localhost:9100"
echo "  - cAdvisor:      http://localhost:8080"