SHELL=/bin/bash

.PHONY: help
help:
	@awk -F':.*##' '/^[-_a-zA-Z0-9]+:.*##/{printf"%-12s\t%s\n",$$1,$$2}' $(MAKEFILE_LIST) | sort

# https://github.com/open-telemetry/opentelemetry-collector/releases
# https://github.com/open-telemetry/opentelemetry-collector-releases/releases
OCB_VERSION=0.122.0

.PHONY: download-ocb
download-ocb: ## Download OpenTelemetry Collector Builder
	curl --proto '=https' --tlsv1.2 -fL -o ocb "https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/cmd%2Fbuilder%2Fv${OCB_VERSION}/ocb_${OCB_VERSION}_darwin_arm64"
	chmod +x ocb

.PHONY: build-otelcol
build-otelcol: ocb ## Build OpenTelemetry Collector
	(cd otelcol && go mod tidy)
	./ocb --config builder-config.yaml --skip-generate

.PHONY: generate-otelcol-code
generate-otelcol-code: ## Generate OpenTelemetry Collector code
	./ocb --config builder-config.yaml --skip-compilation

.PHONY: install-otelcol
install-otelcol: otelcol/otelcol ## Install OpenTelemetry Collector
	sudo cp otelcol/otelcol /usr/local/bin/otelcol
	sudo cp otelcol-config.yaml /usr/local/etc/otelcol-config.yaml
	sudo mkdir -p /var/log/otelcol
	./com.github.open-telemetry.opentelemetry-collector.plist.sh
	sudo cp com.github.open-telemetry.opentelemetry-collector.plist /Library/LaunchDaemons/
	sudo chmod 644 /Library/LaunchDaemons/com.github.open-telemetry.opentelemetry-collector.plist
	sudo chown root:wheel /Library/LaunchDaemons/com.github.open-telemetry.opentelemetry-collector.plist
	sudo launchctl unload /Library/LaunchDaemons/com.github.open-telemetry.opentelemetry-collector.plist
	sudo launchctl load -w /Library/LaunchDaemons/com.github.open-telemetry.opentelemetry-collector.plist

.PHOMY: lint
lint: ## Lint the code
	shellcheck *.sh
	yamllint *.yaml || true
	otelcol/otelcol validate --config otelcol-config.yaml
	plutil -lint com.github.open-telemetry.opentelemetry-collector.plist
