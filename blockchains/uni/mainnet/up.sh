#!/bin/bash
set -eu

# Require profile argument - NO DEFAULT
if [ $# -eq 0 ]; then
    echo "Error: Profile argument is required" 1>&2
    echo "Usage: $0 <prebuilt|dev|release>" 1>&2
    echo "" 1>&2
    echo "Profiles:" 1>&2
    echo "  prebuilt - Use prebuilt binary from GitHub (fastest)" 1>&2
    echo "  dev      - Build from source with dev profile (fast compile, with debug symbols)" 1>&2
    echo "  release  - Build from source with release profile (slow compile, optimized)" 1>&2
    exit 1
fi

PROFILE=$1

# Validate profile
if [[ ! "$PROFILE" =~ ^(prebuilt|dev|release)$ ]]; then
    echo "Error: Invalid profile '$PROFILE'" 1>&2
    echo "Usage: $0 <prebuilt|dev|release>" 1>&2
    exit 1
fi

echo "==> Using profile: $PROFILE"

mkdir -p secrets
if [ ! -f "secrets/jwtsecret" ]; then
    openssl rand -hex 32 | tr -d "\n" >secrets/jwtsecret
    echo "==> Created new jwtsecret"
else
    echo "==> jwtsecret exists already"
fi

# creating shared network if necessary
NETWORK_NAME="shared_network"
if ! docker network ls | grep -q $NETWORK_NAME; then
    echo "==> Creating network: $NETWORK_NAME"
    docker network create $NETWORK_NAME
else
    echo "==> Network $NETWORK_NAME already exists"
fi

if [ -f .env.local ]; then
    set -a # automatically export all variables
    source .env.local
fi

# Launch with the selected profile
echo "==> Starting containers with profile: $PROFILE"
docker compose -f docker-compose.yml -f docker-compose.$PROFILE.yml up --build -d

echo "==> Done! Containers are running."