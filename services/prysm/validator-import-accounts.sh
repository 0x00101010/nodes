#!/bin/bash
set -eu

VALIDATOR_WALLET_FORCE_RECREATE="${VALIDATOR_WALLET_FORCE_RECREATE-:false}"
VALIDATOR_KEYSTORE_DIR="${VALIDATOR_KEYSTORE_DIR:-/config/validator_keys}"
VALIDATOR_KEYSTORE_PASSWORD_FILE="${VALIDATOR_KEYSTORE_PASSWORD_FILE:-/config/keystore-pwd}"
VALIDATOR_WALLET_DIR="${VALIDATOR_WALLET_DIR:-/data/wallet}"
VALIDATOR_WALLET_PASSWORD_FILE="${VALIDATOR_WALLET_PASSWORD_FILE:-/config/wallet-pwd}"

if [ -d "$VALIDATOR_WALLET_DIR" ] && [ "$VALIDATOR_WALLET_FORCE_RECREATE" = "false" ]; then
    echo "$VALIDATOR_WALLET_DIR exists, skip wallet import"
    exit 0
fi

if [ "$VALIDATOR_WALLET_FORCE_RECREATE" = "true" ]; then
    echo "Force re-importing wallet"
fi

./validator \
    accounts import \
    --accept-terms-of-use \
    --$NETWORK \
    --keys-dir=$VALIDATOR_KEYSTORE_DIR \
    --wallet-dir=$VALIDATOR_WALLET_DIR \
    --wallet-password-file=$VALIDATOR_WALLET_PASSWORD_FILE \
    --account-password-file=$VALIDATOR_KEYSTORE_PASSWORD_FILE