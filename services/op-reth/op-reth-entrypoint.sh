#!/bin/bash
set -eu

RETH_DATA_DIR="${RETH_DATA_DIR:-/data}"
RETH_GCMODE="${RETH_GCMODE:-full}"
EL_RPC_PORT="${EL_RPC_PORT:-8545}"
EL_WS_PORT="${EL_WS_PORT:-8546}"
EL_AUTHRPC_PORT="${EL_AUTHRPC_PORT:-8551}"
EL_METRICS_PORT="${EL_METRICS_PORT:-6060}"
RETH_ALLOWED_APIS="${RETH_ALLOWED_APIS:-debug,eth,net,txpool}"

if [[ -z "$RETH_CHAIN" ]]; then
    echo "expected RETH_CHAIN to be set" 1>&2
    exit 1
fi

ADDITIONAL_ARGS=""

if [ "${RETH_GCMODE:-archive}" = "full" ]; then
    ADDITIONAL_ARGS="$ADDITIONAL_ARGS --full"
fi

exec ./op-reth \
    node \
    -vvv \
    --datadir "$RETH_DATA_DIR" \
    --log.stdout.format log-fmt \
    --ws \
    --ws.origins "*" \
    --ws.addr "0.0.0.0" \
    --ws.port "$EL_WS_PORT" \
    --ws.api "$RETH_ALLOWED_APIS" \
    --http \
    --http.corsdomain "*" \
    --http.addr "0.0.0.0" \
    --http.port "$EL_RPC_PORT" \
    --http.api "$RETH_ALLOWED_APIS" \
    --authrpc.addr "0.0.0.0" \
    --authrpc.port "$EL_AUTHRPC_PORT" \
    --authrpc.jwtsecret /config/jwtsecret \
    --metrics "0.0.0.0:$EL_METRICS_PORT" \
    --chain "$RETH_CHAIN" \
    --disable-discovery \
    --rollup.sequencer-http "$RETH_SEQUENCER_HTTP" \
    --rollup.disable-tx-pool-gossip \
    $ADDITIONAL_ARGS

