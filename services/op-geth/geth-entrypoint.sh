#!/bin/bash
set -eu

# 0=silent, 1=error, 2=warn, 3=info, 4=debug, 5=detail
GETH_VERBOSITY="${GETH_VERBOSITY:-3}"
GETH_DATA_DIR="${GETH_DATA_DIR:-/data}"
EL_RPC_PORT="${EL_RPC_PORT:-8545}"
EL_WS_PORT="${EL_WS_PORT:-8546}"
EL_AUTHRPC_PORT="${EL_AUTHRPC_PORT:-8551}"
EL_METRICS_PORT="${EL_METRICS_PORT:-6060}"
EL_P2P_PORT="${EL_P2P_PORT:-30303}"
GETH_GCMODE="${GETH_GCMODE:-full}"
GETH_SYNCMODE="${GETH_SYNCMODE:-snap}"
GETH_STATE_SCHEME="${GETH_STATE_SCHEME:-path}"
GETH_MAX_PEERS="${GETH_MAX_PEERS:-100}"
GETH_ALLOWED_APIS="${GETH_ALLOWED_APIS:-admin,debug,eth,net,txpool,web3}"
GETH_P2P_ENABLE_UPNP="${GETH_P2P_ENABLE_UPNP:-true}"

# setup
mkdir -p $GETH_DATA_DIR

# dynamically configure ADDITIONAL_ARGS
ADDITIONAL_ARGS=""

if [ "$GETH_P2P_ENABLE_UPNP" = "true" ]; then
	ADDITIONAL_ARGS="$ADDITIONAL_ARGS --nat=upnp"
elif [ "${GETH_P2P_ADDRESS:+x}" = x ]; then
    ADDITIONAL_ARGS="$ADDITIONAL_ARGS --nat=extip:$GETH_P2P_ADDRESS"
fi

# if [ "${GETH_ALLOW_UNPROTECTED_TXS+x}" = x ]; then
#     ADDITIONAL_ARGS="$ADDITIONAL_ARGS --rpc.allow-unprotected-txs=$GETH_ALLOW_UNPROTECTED_TXS"
# fi

exec ./geth \
    --datadir="$GETH_DATA_DIR" \
    --verbosity="$GETH_VERBOSITY" \
    --http \
    --http.corsdomain="*" \
    --http.vhosts="*" \
    --http.addr=0.0.0.0 \
    --http.port="$EL_RPC_PORT" \
    --http.api="$GETH_ALLOWED_APIS" \
    --authrpc.addr=0.0.0.0 \
    --authrpc.port="$EL_AUTHRPC_PORT" \
    --authrpc.vhosts="*" \
    --authrpc.jwtsecret=/config/jwtsecret \
    --ws \
    --ws.addr=0.0.0.0 \
    --ws.port="$EL_WS_PORT" \
    --ws.origins="*" \
    --ws.api="$GETH_ALLOWED_APIS" \
    --metrics \
    --metrics.addr=0.0.0.0 \
    --metrics.port="$EL_METRICS_PORT" \
    --syncmode="$GETH_SYNCMODE" \
    --gcmode="$GETH_GCMODE" \
    --state.scheme="$GETH_STATE_SCHEME" \
    --maxpeers="$GETH_MAX_PEERS" \
    --port="$EL_P2P_PORT" \
    --op-network="$OP_NODE_NETWORK" \
    $ADDITIONAL_ARGS # intentionally unquoted