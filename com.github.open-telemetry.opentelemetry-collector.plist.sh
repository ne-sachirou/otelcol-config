#!/bin/bash
set -eu

PLIST=$(cat <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>com.github.open-telemetry.opentelemetry-collector</string>

    <key>ProgramArguments</key>
    <array>
      <string>/usr/local/bin/otelcol</string>
      <string>--config</string>
      <string>/usr/local/etc/otelcol-config.yaml</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
      <key>MACKEREL_APIKEY</key>
      <string>${MACKEREL_APIKEY}</string>
    </dict>

    <key>StandardOutPath</key>
    <string>/var/log/otelcol/stdout.log</string>
    <key>StandardErrorPath</key>
    <string>/var/log/otelcol/stdout.log</string>

    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
  </dict>
</plist>
PLIST
)

echo "$PLIST" > com.github.open-telemetry.opentelemetry-collector.plist
