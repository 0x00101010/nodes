#!/bin/bash
set -eu

# Logging verbosity. (trace, debug, info, warn, error, fatal, panic) (default: "info")
BEACON_NODE_LOG_VERBOSITY="${BEACON_NODE_LOG_VERBOSITY:-info}"
BEACON_NODE_DATA_DIR="${BEACON_NODE_DATA_DIR:-/data/beacon-node}"
BEACON_NODE_ENABLE_UPNP="${BEACON_NODE_ENABLE_UPNP:-true}"
BEACON_NODE_EXECUTION_LOCAL_NAME="${BEACON_NODE_EXECUTION_LOCAL_NAME:-http://geth}"
BEACON_NODE_EXECUTION_AUTH_RPC_PORT="${BEACON_NODE_EXECUTION_AUTH_RPC_PORT:-8551}"
BEACON_NODE_EXECUTION_ENDPOINT="$BEACON_NODE_EXECUTION_LOCAL_NAME:$BEACON_NODE_EXECUTION_AUTH_RPC_PORT"
BEACON_NODE_METRICS_PORT="${BEACON_NODE_METRICS_PORT:-8080}"
BEACON_NODE_P2P_PORT="${BEACON_NODE_P2P_PORT:-13000}"
BEACON_NODE_GRPC_PORT="${BEACON_NODE_GRPC_PORT:-3500}"
BEACON_NODE_RPC_PORT="${BEACON_NODE_RPC_PORT:-4000}"

# dynamically configure ADDITIONAL_ARGS
ADDITIONAL_ARGS=""

if [ -n "$NETWORK" ]; then
    ADDITIONAL_ARGS="$ADDITIONAL_ARGS --$NETWORK"
fi

if [ "$BEACON_NODE_ENABLE_UPNP" = "true" ]; then
	ADDITIONAL_ARGS="$ADDITIONAL_ARGS --enable-upnp"
elif [ -n "$BEACON_NODE_P2P_HOST_IP" ]; then
    ADDITIONAL_ARGS="$ADDITIONAL_ARGS --p2p-host-ip=$BEACON_NODE_P2P_HOST_IP"
fi

if [ -n "$BEACON_NODE_CHECKPOINT_SYNC_URL" ]; then
    ADDITIONAL_ARGS="$ADDITIONAL_ARGS --checkpoint-sync-url=$BEACON_NODE_CHECKPOINT_SYNC_URL --genesis-beacon-api-url=$BEACON_NODE_CHECKPOINT_SYNC_URL"
fi

if [ -n "$BEACON_NODE_SUGGESTED_FEE_RECIPIENT" ]; then
    ADDITIONAL_ARGS="$ADDITIONAL_ARGS --suggested-fee-recipient=$BEACON_NODE_SUGGESTED_FEE_RECIPIENT"
else
    echo "BEACON_NODE_SUGGESTED_FEE_RECIPIENT must be set"
    exit 1
fi

exec ./beacon-node \
    --accept-terms-of-use \
    --verbosity="$BEACON_NODE_LOG_VERBOSITY" \
    --datadir="$BEACON_NODE_DATA_DIR" \
    --execution-endpoint="$BEACON_NODE_EXECUTION_ENDPOINT" \
    --jwt-secret=/config/jwtsecret \
    --rpc-host 0.0.0.0 \
    --rpc-port "$BEACON_NODE_RPC_PORT" \
    --grpc-gateway-host 0.0.0.0 \
    --grpc-gateway-port "$BEACON_NODE_GRPC_PORT" \
    --p2p-local-ip 0.0.0.0 \
    --p2p-tcp-port "$BEACON_NODE_P2P_PORT" \
    --p2p-udp-port "$BEACON_NODE_P2P_PORT" \
    --monitoring-host 0.0.0.0 \
    --monitoring-port "$BEACON_NODE_METRICS_PORT" \
    $ADDITIONAL_ARGS # intentionally unquoted