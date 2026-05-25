#!/bin/bash
set -eu

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

# Source .env (and .env.local if present) so we can inspect SNAPSHOT_MODE
# before invoking docker compose.
set -a
# .env.local first so .env can reference vars from it (e.g. MAINNET_L1_ETH_RPC)
# shellcheck disable=SC1091
[ -f .env.local ] && . ./.env.local
# shellcheck disable=SC1091
[ -f .env ] && . ./.env
set +a

# When downloading a snapshot, the el-snapshot-init container must actually
# re-run. docker compose's --force-recreate is unreliable for one-shot init
# containers that are already in "Exited 0" state: it can skip recreating
# them and reuse the stale completed state, in which case the new
# SNAPSHOT_MODE value never reaches the container. A full `down` guarantees
# the init container is recreated from scratch on the next `up`. Volumes
# survive `down`, and snapshot-init wipes the data dir itself in download
# mode.
if [ "${SNAPSHOT_MODE:-skip}" = "download" ]; then
    echo "==> SNAPSHOT_MODE=download: tearing down stack so snapshot-init re-runs"
    docker compose down --remove-orphans
fi

echo "==> Starting containers"
docker compose up --build -d --force-recreate

echo "==> Done! Containers are running."
