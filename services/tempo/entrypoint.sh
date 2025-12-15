#!/bin/bash
set -eu

TEMPO_DATA_DIR="${TEMPO_DATA_DIR:-/data}"
TEMPO_LOG_LEVEL="${TEMPO_LOG_LEVEL:-info}"
TEMPO_RPC_PORT="${TEMPO_RPC_PORT:-8545}"
TEMPO_ALLOWED_APIS="${TEMPO_ALLOWED_APIS:-eth,net,web3,txpool,trace}"
TEMPO_METRICS_PORT="${TEMPO_METRICS_PORT:-6060}"

ADDITIONAL_ARGS=""

# /// Set the minimum log level.
# ///
# /// -v      Errors
# /// -vv     Warnings
# /// -vvv    Info
# /// -vvvv   Debug
# /// -vvvvv  Traces (warning: very verbose!)
RETH_LOG_LEVEL="${RETH_LOG_LEVEL:-info}"
LOG_FLAG=""

case "${RETH_LOG_LEVEL,,}" in
    error)
        LOG_FLAG="-v"
        ;;
    warn|warning)
        LOG_FLAG="-vv"
        ;;
    info)
        LOG_FLAG="-vvv"
        ;;
    debug)
        LOG_FLAG="-vvvv"
        ;;
    trace)
        LOG_FLAG="-vvvvv"
        ;;
    *)
        echo "Invalid RETH_LOG_LEVEL: $RETH_LOG_LEVEL. Must be one of: error, warn, info, debug, trace" 1>&2
        exit 1
        ;;
esac

exec ./tempo \
    node \
    $LOG_FLAG \
    --full \
    --datadir "$TEMPO_DATA_DIR" \
    --follow \
    --http \
    --http.addr "0.0.0.0" \
    --http.port "$TEMPO_RPC_PORT" \
    --http.api "$TEMPO_ALLOWED_APIS" \
    --metrics "0.0.0.0:$TEMPO_METRICS_PORT" \
    --port "$TEMPO_P2P_PORT" \
    --discovery.port "$TEMPO_P2P_PORT" \
    --discovery.v5.port "$TEMPO_P2P_PORT" \
    $ADDITIONAL_ARGS
