SHELL=/bin/bash

.PHONY: help
help:
	@awk -F':.*##' '/^[-_a-zA-Z0-9]+:.*##/{printf"%-12s\t%s\n",$$1,$$2}' $(MAKEFILE_LIST) | sort

.PHONY: build-otelcol
build-otelcol: ## Build OpenTelemetry Collector
	(cd otelcol && go build -o otelcol .)

.PHONY: generate-otelcol-code
generate-otelcol-code: ## Generate OpenTelemetry Collector code
	go get ./... && go mod tidy && go generate ./...

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
lint: lint-gha lint-otelcol lint-renovate ## Lint the code
	shellcheck *.sh
	plutil -lint com.github.open-telemetry.opentelemetry-collector.plist

lint-gha:
	yamllint .github/workflows/
	actionlint
	ghalint run
	zizmor .

lint-otelcol:
	yamllint builder-config.yaml otelcol-config.yaml
	otelcol/otelcol validate --config otelcol-config.yaml

lint-renovate:
	npx --package renovate -- renovate-config-validator
	yamllint .github/dependabot.yml

status: ## Show status of OpenTelemetry Collector service
	sudo launchctl list | grep opentelemetry-collector
	sudo lsof -iTCP:4317,4318 || true
	tail -f /var/log/otelcol/stdout.log
