#!/bin/bash
set -eu

PROMETHEUS_PORT="${PROMETHEUS_PORT:-9090}"
PROMETHEUS_LOG_LEVEL="${PROMETHEUS_LOG_LEVEL:-info}"
TEMPLATE_CONFIG_FILE="${TEMPLATE_CONFIG_FILE:-./prometheus-config-template.yml}"
envsubst < $TEMPLATE_CONFIG_FILE > "prometheus.yml"

exec ./prometheus \
    --log.level="$PROMETHEUS_LOG_LEVEL" \
    --storage.tsdb.path=/data \
    --storage.tsdb.retention.time=$PROMETHEUS_DATA_RETENTION_TIME \
    --web.listen-address="0.0.0.0:$PROMETHEUS_PORT"