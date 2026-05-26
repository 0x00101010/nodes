#!/bin/bash
#
# Snapshot init container entrypoint.
#
# Modes (via SNAPSHOT_MODE):
#   skip     - no-op, exit 0. Reth uses whatever already exists in SNAPSHOT_DATA_DIR.
#   download - download a snapshot via aria2c, extract .tar.zst into
#              SNAPSHOT_DATA_DIR. Fresh downloads wipe SNAPSHOT_DATA_DIR;
#              interrupted downloads are resumed without wiping first.
#
# Env vars:
#   SNAPSHOT_MODE                  skip | download                (default: skip)
#   SNAPSHOT_BASE_URL              required when mode=download
#   SNAPSHOT_VERSION               'latest' or explicit filename  (default: latest)
#   SNAPSHOT_DATA_DIR              where reth data lives          (default: /data)
#   SNAPSHOT_WORK_DIR              where aria2c stores download   (default: $DATA_DIR/_snapshot)
#   SNAPSHOT_ARIA2_CONNECTIONS     -x / -s value for aria2c       (default: 16)

set -euo pipefail

log() { echo "[snapshot-init] $*"; }
err() { echo "[snapshot-init] $*" 1>&2; }

MODE="${SNAPSHOT_MODE:-skip}"
DATA_DIR="${SNAPSHOT_DATA_DIR:-/data}"
WORK_DIR="${SNAPSHOT_WORK_DIR:-${DATA_DIR}/_snapshot}"
CONN="${SNAPSHOT_ARIA2_CONNECTIONS:-16}"

case "$MODE" in
    skip)
        log "SNAPSHOT_MODE=skip -> leaving ${DATA_DIR} untouched"
        exit 0
        ;;
    download)
        ;;
    *)
        err "invalid SNAPSHOT_MODE='${MODE}' (expected: skip|download)"
        exit 1
        ;;
esac

if [ -z "${SNAPSHOT_BASE_URL:-}" ]; then
    err "SNAPSHOT_BASE_URL must be set when SNAPSHOT_MODE=download"
    exit 1
fi

VERSION="${SNAPSHOT_VERSION:-latest}"

if [ "$VERSION" = "latest" ]; then
    log "resolving latest snapshot filename from ${SNAPSHOT_BASE_URL}/latest"
    FILENAME="$(curl -fsSL "${SNAPSHOT_BASE_URL}/latest" | tr -d '\r\n')"
    if [ -z "$FILENAME" ]; then
        err "GET ${SNAPSHOT_BASE_URL}/latest returned an empty body"
        exit 1
    fi
else
    FILENAME="$VERSION"
fi

URL="${SNAPSHOT_BASE_URL}/${FILENAME}"
LOCAL_NAME="$(basename "$FILENAME")"

log "snapshot URL : ${URL}"
log "data dir     : ${DATA_DIR}"
log "work dir     : ${WORK_DIR}"
log "aria2 conns  : ${CONN}"

RESUME_DOWNLOAD=false
if [ -f "${WORK_DIR}/${LOCAL_NAME}.aria2" ] || [ -f "${WORK_DIR}/${LOCAL_NAME}" ]; then
    RESUME_DOWNLOAD=true
fi

mkdir -p "$DATA_DIR" "$WORK_DIR"

if [ "$RESUME_DOWNLOAD" = "true" ]; then
    log "found existing snapshot download for ${LOCAL_NAME}; preserving ${DATA_DIR} and resuming"
else
    log "wiping ${DATA_DIR} (preserving ${WORK_DIR})"
    find "$DATA_DIR" -mindepth 1 -maxdepth 1 ! -path "$WORK_DIR" -exec rm -rf {} +
fi

log "downloading snapshot via aria2c"
aria2c \
    --continue=true \
    --max-connection-per-server="$CONN" \
    --split="$CONN" \
    --dir="$WORK_DIR" \
    --out="$LOCAL_NAME" \
    --console-log-level=warn \
    --summary-interval=10 \
    "$URL"

log "extracting ${WORK_DIR}/${LOCAL_NAME} -> ${DATA_DIR}"
zstd -d -c "${WORK_DIR}/${LOCAL_NAME}" | tar -xf - -C "$DATA_DIR"

log "cleanup: removing ${WORK_DIR}"
rm -rf "$WORK_DIR"

log "done"
