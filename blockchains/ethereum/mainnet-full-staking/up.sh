#!/bin/bash
set -eu

mkdir -p secrets
if [ ! -f "secrets/jwtsecret" ]; then
    openssl rand -hex 32 | tr -d "\n" >secrets/jwtsecret
else
    echo "jwtsecret exists already..."
fi

# creating shared network if necessary
NETWORK_NAME="shared_network"
if ! docker network ls | grep -q $NETWORK_NAME; then
    echo "Creating network: $NETWORK_NAME"
    docker network create $NETWORK_NAME
else
    echo "Network $NETWORK_NAME already exists"
fi

docker compose up --build -d