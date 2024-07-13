#!/bin/bash
set -eu

# 0=silent, 1=error, 2=warn, 3=info, 4=debug, 5=detail
GETH_VERBOSITY=${GETH_VERBOSITY:-3}
GETH_DATA_DIR=/data
GETH_RPC_PORT="${GETH_RPC_PORT:-8545}"
GETH_WS_PORT="${GETH_WS_PORT:-8546}"
GETH_AUTHRPC_PORT="${GETH_AUTHRPC_PORT:-8551}"
GETH_METRICS_PORT="${GETH_METRICS_PORT:-6060}"
GETH_P2P_PORT="${GETH_P2P_PORT:-30303}"
GETH_GCMODE="${GETH_GCMODE:-full}"
GETH_SYNCMODE="${GETH_SYNCMODE:-full}"
GETH_STATE_SCHEME="${GETH_STATE_SCHEME:-path}"
GETH_MAX_PEERS="${GETH_MAX_PEERS:-100}"
if [ -f /config/jwtsecret ]; then
    GETH_ENGINE_AUTH=$(cat /config/jwtsecret)
fi

# setup
mkdir -p $GETH_DATA_DIR
HOST_IP="" # put your external IP address here and open port 30303 to improve peer connectivity


# dynamically configure ADDITIONAL_ARGS
ADDITIONAL_ARGS=""

if [ "${GETH_SEPOIA:+x}" = x ]; then
    ADDITIONAL_ARGS="$ADDITIONAL_ARGS --sepolia"
fi

if [ "${GETH_MAINNET:+x}" = x ]; then
    ADDITIONAL_ARGS="$ADDITIONAL_ARGS --mainnet"
fi

if [ "${GETH_HOLESKY:+x}" = x ]; then
    ADDITIONAL_ARGS="$ADDITIONAL_ARGS --holesky"
fi

# if [ "${GETH_ALLOW_UNPROTECTED_TXS+x}" = x ]; then
#     ADDITIONAL_ARGS="$ADDITIONAL_ARGS --rpc.allow-unprotected-txs=$GETH_ALLOW_UNPROTECTED_TXS"
# fi

if [ "${HOST_IP:+x}" = x ]; then
	ADDITIONAL_ARGS="$ADDITIONAL_ARGS --nat=extip:$HOST_IP"
fi 

exec ./geth \
    --datadir="$GETH_DATA_DIR" \
    --verbosity="$GETH_VERBOSITY" \
    --http \
    --http.corsdomain="*" \
    --http.vhosts="*" \
    --http.addr=0.0.0.0 \
    --http.port="$GETH_RPC_PORT" \
    --http.api=web3,debug,eth,net,engine \
    --authrpc.addr=0.0.0.0 \
    --authrpc.port="$GETH_AUTHRPC_PORT" \
    --authrpc.vhosts="*" \
    --authrpc.jwtsecret="$GETH_ENGINE_AUTH" \
    --ws \
    --ws.addr=0.0.0.0 \
    --ws.port="$GETH_WS_PORT" \
    --ws.origins="*" \
    --ws.api=debug,eth,net,engine \
    --metrics \
    --metrics.addr=0.0.0.0 \
    --metrics.port="$GETH_METRICS_PORT" \
    --syncmode="$GETH_SYNCMODE" \
    --gcmode="$GETH_GCMODE" \
    --state.scheme="$GETH_STATE_SCHEME" \
    --maxpeers="$GETH_MAX_PEERS" \
    --port="$GETH_P2P_PORT" \
    $ADDITIONAL_ARGS # intentionally unquoted