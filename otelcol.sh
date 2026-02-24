#!/bin/bash
set -eu

PIDFILE=/var/run/otelcol.pid

echo "$$" > "$PIDFILE"
trap 'rm -f "$PIDFILE"' EXIT

. /usr/local/etc/otelcol/otelcol.env
export MACKEREL_APIKEY

exec /usr/local/bin/otelcol --config /usr/local/etc/otelcol/config.yaml
