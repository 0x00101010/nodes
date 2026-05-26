#!/bin/bash
set -eu

RETH_DATA_DIR="${RETH_DATA_DIR:-/data}"
RETH_GCMODE="${RETH_GCMODE:-full}"
EL_RPC_PORT="${EL_RPC_PORT:-8545}"
EL_WS_PORT="${EL_WS_PORT:-8546}"
EL_AUTHRPC_PORT="${EL_AUTHRPC_PORT:-8551}"
EL_METRICS_PORT="${EL_METRICS_PORT:-6060}"
EL_P2P_PORT="${EL_P2P_PORT:-30303}"
EL_DISCOVERY_V5_PORT="${EL_DISCOVERY_V5_PORT:-9200}"
EL_MAX_OUTBOUND_PEERS="${EL_MAX_OUTBOUND_PEERS:-100}"
RETH_ALLOWED_APIS="${RETH_ALLOWED_APIS:-debug,eth,net,txpool}"

if [[ -z "${RETH_CHAIN:-}" ]]; then
    echo "expected RETH_CHAIN to be set" 1>&2
    exit 1
fi

ADDITIONAL_ARGS=""

if [ "${RETH_GCMODE:-archive}" = "full" ]; then
    ADDITIONAL_ARGS="$ADDITIONAL_ARGS --full"
fi

if [ "${RETH_SEQUENCER_HTTP+x}" = x ]; then
    ADDITIONAL_ARGS="$ADDITIONAL_ARGS --rollup.sequencer-http $RETH_SEQUENCER_HTTP"
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

if [ "${RETH_PROOFS_HISTORY_STORAGE_PATH+x}" = x ] && [ "${RETH_PROOFS_HISTORY_INIT:-true}" = "true" ]; then
    /app/base-reth-node \
        node \
        $LOG_FLAG \
        --chain "$RETH_CHAIN" \
        --datadir "$RETH_DATA_DIR" \
        --log.stdout.format log-fmt \
        --http \
        --http.addr "127.0.0.1" \
        --http.port "$EL_RPC_PORT" \
        --http.api eth \
        $ADDITIONAL_ARGS &

    RETH_PID=$!
    MAX_WAIT="${RETH_PROOFS_HISTORY_INIT_MAX_WAIT_SECONDS:-21600}"

    while true; do
        RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest", false],"id":1}' "http://127.0.0.1:$EL_RPC_PORT" 2>/dev/null || true)
        BLOCK_NUMBER=$(printf '%s' "$RESPONSE" | jq -r '.result.number // empty' 2>/dev/null || true)

        if [ "$BLOCK_NUMBER" = "0x0" ]; then
            echo "waiting for reth node to sync beyond genesis block"
        elif [ -n "$BLOCK_NUMBER" ]; then
            break
        else
            echo "waiting for reth node to start up"
        fi

        if ! kill -0 "$RETH_PID" 2>/dev/null; then
            echo "reth node exited before proofs init readiness" 1>&2
            wait "$RETH_PID" || true
            exit 1
        fi

        sleep 1
        MAX_WAIT=$((MAX_WAIT - 1))
        if [ "$MAX_WAIT" -eq 0 ]; then
            echo "timed out waiting for reth node to start up" 1>&2
            kill "$RETH_PID" || true
            exit 1
        fi
    done

    kill "$RETH_PID" || true
    wait "$RETH_PID" || echo "warning: reth node exited with code $?"

    /app/base-reth-node \
        proofs \
        init \
        $LOG_FLAG \
        --log.stdout.format log-fmt \
        --chain "$RETH_CHAIN" \
        --datadir "$RETH_DATA_DIR" \
        --proofs-history.storage-path "$RETH_PROOFS_HISTORY_STORAGE_PATH"
fi

if [ "${RETH_PROOFS_HISTORY_STORAGE_PATH+x}" = x ]; then
    ADDITIONAL_ARGS="$ADDITIONAL_ARGS --proofs-history --proofs-history.storage-path $RETH_PROOFS_HISTORY_STORAGE_PATH"
fi

if [ "${RETH_PROOFS_HISTORY_WINDOW+x}" = x ]; then
    ADDITIONAL_ARGS="$ADDITIONAL_ARGS --proofs-history.window $RETH_PROOFS_HISTORY_WINDOW"
fi

if [ "${RETH_PROOFS_HISTORY_PRUNE_INTERVAL+x}" = x ]; then
    ADDITIONAL_ARGS="$ADDITIONAL_ARGS --proofs-history.prune-interval $RETH_PROOFS_HISTORY_PRUNE_INTERVAL"
fi

if [ "${RETH_PROOFS_HISTORY_VERIFICATION_INTERVAL+x}" = x ]; then
    ADDITIONAL_ARGS="$ADDITIONAL_ARGS --proofs-history.verification-interval $RETH_PROOFS_HISTORY_VERIFICATION_INTERVAL"
fi

exec /app/base-reth-node \
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
    --discovery.v5.port "$EL_DISCOVERY_V5_PORT" \
    --port "$EL_P2P_PORT" \
    --max-outbound-peers "$EL_MAX_OUTBOUND_PEERS" \
    --rollup.disable-tx-pool-gossip \
    $ADDITIONAL_ARGS
