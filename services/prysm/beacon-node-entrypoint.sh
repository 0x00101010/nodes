#!/bin/bash
set -eu

# Logging verbosity. (trace, debug, info, warn, error, fatal, panic) (default: "info")
BEACON_NODE_LOG_VERBOSITY="${BEACON_NODE_LOG_VERBOSITY:-info}"
BEACON_NODE_DATA_DIR="${BEACON_NODE_DATA_DIR:-/data/beacon-node}"
BEACON_NODE_ENABLE_UPNP="${BEACON_NODE_ENABLE_UPNP:-false}"
BEACON_NODE_EL_ENDPOINT="http://$EL_DNS:$EL_AUTHRPC_PORT"
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
elif [ -n "$BEACON_NODE_ENABLE_PUBLIC_IP" ]; then
    ADDITIONAL_ARGS="$ADDITIONAL_ARGS --p2p-host-ip=$(curl -s ifconfig.me)"
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

if [ "${MEV_BOOST_DNS+x}" = x ] && [ "${MEV_BOOST_PORT+x}" = x ]; then
    ADDITIONAL_ARGS="$ADDITIONAL_ARGS --http-mev-relay=$MEV_BOOST_DNS:$MEV_BOOST_PORT"
fi

exec ./beacon-node \
    --accept-terms-of-use \
    --verbosity="$BEACON_NODE_LOG_VERBOSITY" \
    --datadir="$BEACON_NODE_DATA_DIR" \
    --execution-endpoint="$BEACON_NODE_EL_ENDPOINT" \
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