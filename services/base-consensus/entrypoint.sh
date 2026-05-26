#!/bin/bash
#
# base-consensus entrypoint.
#
# base-consensus auto-binds every CLI flag from BASE_NODE_* env vars via clap.
set -eu

BASE_NODE_COMMAND="${BASE_NODE_COMMAND:-node}"

case "$BASE_NODE_COMMAND" in
    node|follow)
        exec /app/base-consensus "$BASE_NODE_COMMAND"
        ;;
    *)
        echo "Invalid BASE_NODE_COMMAND: $BASE_NODE_COMMAND. Must be one of: node, follow" 1>&2
        exit 1
        ;;
esac
