#!/bin/bash
set -eu

PIDFILE=/var/run/otelcol.pid

echo "$$" > "$PIDFILE"
trap 'rm -f "$PIDFILE"' EXIT

exec /usr/local/bin/otelcol --config /usr/local/etc/otelcol-config.yaml
