#!/bin/bash
set -eu

mkdir -p secrets
openssl rand -hex 32 | tr -d "\n" >secrets/jwtsecret

# creating shared network if necessary
NETWORK_NAME="shared_network"
if ! docker network ls | grep -q $NETWORK_NAME; then
    echo "Creating network: $NETWORK_NAME"
    docker network create $NETWORK_NAME
else
    echo "Network $NETWORK_NAME already exists"
fi

docker compose up --build -d
