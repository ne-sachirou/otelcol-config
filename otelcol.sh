#!/bin/bash
set -eu

PIDFILE=/var/run/otelcol.pid
ENVFILE=/usr/local/etc/otelcol/otelcol.env

cleanup() {
  rm -f "$PIDFILE"
}

forward_terminate() {
  if [ -n "${CHILD_PID:-}" ] && kill -0 "$CHILD_PID" 2>/dev/null; then
    kill -TERM "$CHILD_PID"
    wait "$CHILD_PID" || true
  fi
  exit 0
}

trap cleanup EXIT
trap forward_terminate TERM INT HUP

set -a
# shellcheck disable=SC1090
. "$ENVFILE"
set +a

: "${MACKEREL_APIKEY:?MACKEREL_APIKEY is not set}"

echo "$$" > "$PIDFILE"

/usr/local/bin/otelcol --config /usr/local/etc/otelcol/config.yaml &
CHILD_PID=$!
wait "$CHILD_PID"
