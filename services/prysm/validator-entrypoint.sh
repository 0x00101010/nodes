#!/bin/bash
set -eu

VALIDATOR_WALLET_DIR="${VALIDATOR_WALLET_DIR:-/data/wallet}"
VALIDATOR_DATA_DIR="${VALIDATOR_DATA_DIR:-/data/validator}"
VALIDATOR_GRAFFITI="${VALIDATOR_GRAFFITI:-0x00101010}"
VALIDATOR_RPC_GATEWAY_PROVIDER="$CL_BEACON_NODE_DNS:$BEACON_NODE_GRPC_PORT"
VALIDATOR_RPC_PROVIDER="$CL_BEACON_NODE_DNS:$BEACON_NODE_RPC_PORT"

ADDITIONAL_ARGS=""

./validator \
    --accept-terms-of-use \
    --$NETWORK \
    --wallet-dir=$VALIDATOR_WALLET_DIR \
    --wallet-password-file=$VALIDATOR_WALLET_PASSWORD_FILE \
    --datadir=$VALIDATOR_DATA_DIR \
    --graffiti=$VALIDATOR_GRAFFITI \
    --suggested-fee-recipient=$VALIDATOR_SUGGESTED_FEE_RECIPIENT \
    --beacon-rest-api-provider=$VALIDATOR_RPC_GATEWAY_PROVIDER \
    --beacon-rpc-provider=$VALIDATOR_RPC_PROVIDER \
    --monitoring-host=0.0.0.0 \
    --monitoring-port=$VALIDATOR_METRICS_PORT \
    $ADDITIONAL_ARGS # intentionally unquoted