#!/bin/bash
set -eu

# Logging verbosity. (trace, debug, info, warn, error, fatal, panic) (default: "info")
BEACON_NODE_LOG_VERBOSITY="${BEACON_NODE_LOG_VERBOSITY:-info}"
BEACON_NODE_DATA_DIR="${BEACON_NODE_DATA_DIR:-/data/beacon-node}"
BEACON_NODE_EL_ENDPOINT="http://$EL_DNS:$EL_AUTHRPC_PORT"
BEACON_NODE_METRICS_PORT="${BEACON_NODE_METRICS_PORT:-8080}"
BEACON_NODE_P2P_PORT="${BEACON_NODE_P2P_PORT:-13000}"
BEACON_NODE_GRPC_PORT="${BEACON_NODE_GRPC_PORT:-3500}"
BEACON_NODE_RPC_PORT="${BEACON_NODE_RPC_PORT:-4000}"

# dynamically configure ADDITIONAL_ARGS
ADDITIONAL_ARGS=""

if [ "${NETWORK+x}" = x ]; then
    ADDITIONAL_ARGS="$ADDITIONAL_ARGS --network $NETWORK"
fi

if [ "${BEACON_NODE_ENABLE_UPNP+x}" = x ]; then
	ADDITIONAL_ARGS="$ADDITIONAL_ARGS --enable-upnp"
elif [ "${BEACON_NODE_P2P_HOST_IP+x}" = x ]; then
    ADDITIONAL_ARGS="$ADDITIONAL_ARGS --enr-address $BEACON_NODE_P2P_HOST_IP"
fi

exec ./lighthouse \
    bn \
    --checkpoint-sync-url $BEACON_NODE_CHECKPOINT_SYNC_URL \
    --disable-backfill-rate-limiting \
    --datadir $BEACON_NODE_DATA_DIR \
    --debug-level $BEACON_NODE_LOG_VERBOSITY \
    --execution-endpoint $BEACON_NODE_EL_ENDPOINT \
    --jwt-secrets /config/jwtsecret \
    --http \
    --http-address 0.0.0.0 \
    --http-port $BEACON_NODE_RPC_PORT \
    --port $BEACON_NODE_P2P_PORT \
    --metrics \
    --metrics-address 0.0.0.0 \
    --metrics-port $BEACON_NODE_METRICS_PORT \
    $ADDITIONAL_ARGS # intentionally unquoted
    