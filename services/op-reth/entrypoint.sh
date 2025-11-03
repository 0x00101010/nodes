#!/bin/bash
set -eu

RETH_DATA_DIR="${RETH_DATA_DIR:-/data}"
RETH_GCMODE="${RETH_GCMODE:-full}"
EL_RPC_PORT="${EL_RPC_PORT:-8545}"
EL_WS_PORT="${EL_WS_PORT:-8546}"
EL_AUTHRPC_PORT="${EL_AUTHRPC_PORT:-8551}"
EL_METRICS_PORT="${EL_METRICS_PORT:-6060}"
EL_P2P_PORT="${EL_P2P_PORT:-30303}"
RETH_ALLOWED_APIS="${RETH_ALLOWED_APIS:-debug,eth,net,txpool}"

if [[ -z "$RETH_CHAIN" ]]; then
    echo "expected RETH_CHAIN to be set" 1>&2
    exit 1
fi

if [[ -z "$RETH_BIN" ]]; then
    echo "expected RETH_BIN to be set" 1>&2
    exit 1
fi

ADDITIONAL_ARGS=""

if [ "${RETH_GCMODE:-archive}" = "full" ]; then
    ADDITIONAL_ARGS="$ADDITIONAL_ARGS --full"
fi

if [ "${RETH_SEQUENCER_HTTP+x}" = x ]; then
    ADDITIONAL_ARGS="$ADDITIONAL_ARGS --rollup.sequencer-http $RETH_SEQUENCER_HTTP"
fi

if [ "${RETH_FLASHBLOCKS_URL+x} = x" ]; then
    ADDITIONAL_ARGS="$ADDITIONAL_ARGS --flashblocks-url $RETH_FLASHBLOCKS_URL"
fi

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

exec ./$RETH_BIN \
    node \
    $LOG_FLAG \
    --chain "$RETH_CHAIN" \
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
    --discovery.port "$EL_P2P_PORT" \
    --port "$EL_P2P_PORT" \
    # --disable-discovery \
    # --rollup.disable-tx-pool-gossip \
    $ADDITIONAL_ARGS

