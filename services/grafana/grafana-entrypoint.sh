#!/bin/bash
set -eu

find "/app/dashboards" -type f -name "*.json.tpl" | while read -r file; do
    echo "Processing $file..."
    envsubst < $file > "${file%.tpl}"
    rm "$file"
done

exec ./grafana/bin/grafana \
    server \
    --homepath=grafana \
    --config=grafana-config.ini