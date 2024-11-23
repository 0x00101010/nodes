#!/bin/bash
set -eu

if [[ -z "$OP_NODE_NETWORK" && -z "$OP_NODE_ROLLUP_CONFIG" ]]; then
  echo "expected OP_NODE_NETWORK to be set" 1>&2
  exit 1
fi

exec ./op-node