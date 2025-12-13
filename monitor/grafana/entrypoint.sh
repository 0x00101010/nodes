#!/bin/bash
set -eu

exec ./grafana/bin/grafana \
    server \
    --homepath=grafana