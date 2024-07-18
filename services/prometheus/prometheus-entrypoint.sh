#!/bin/bash
set -eu

PROMETHEUS_PORT="${PROMETHEUS_PORT:-9090}"
TEMPLATE_CONFIG_FILE="${TEMPLATE_CONFIG_FILE:-./prometheus-config-template.yml}"
envsubst < $TEMPLATE_CONFIG_FILE > "prometheus.yml"

exec ./prometheus \
    --log.level=debug \
    --web.listen-address="0.0.0.0:$PROMETHEUS_PORT"