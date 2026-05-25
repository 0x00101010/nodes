#!/bin/bash
#
# base-consensus entrypoint.
#
# base-consensus auto-binds every CLI flag from BASE_NODE_* env vars via clap.
# All configuration lives in the per-network .env file, so this script is a
# thin exec wrapper.
set -eu

exec /app/base-consensus node
