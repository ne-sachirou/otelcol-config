SHELL=/bin/bash

.PHONY: help
help:
	@awk -F':.*##' '/^[-_a-zA-Z0-9]+:.*##/{printf"%-12s\t%s\n",$$1,$$2}' $(MAKEFILE_LIST) | sort

.PHONY: build-otelcol
build-otelcol: ## OpenTelemetry Collectorをbuildする
	(cd otelcol && go build -o otelcol .)

.PHONY: generate-otelcol-code
generate-otelcol-code: ## OpenTelemetry Collectorのcodeを生成する
	go get ./... && go mod tidy && go generate ./...

.PHONY: install-otelcol
install-otelcol: otelcol/otelcol ## build濟みのOpenTelemetry Collectorをinstallする
	sudo cp otelcol/otelcol /usr/local/bin/otelcol
	sudo cp otelcol.sh /usr/local/bin/otelcol.sh
	sudo chmod 755 /usr/local/bin/otelcol.sh
	sudo chown root:wheel /usr/local/bin/otelcol.sh

	sudo mkdir -p /usr/local/etc/otelcol
	sudo cp otelcol-config.yaml /usr/local/etc/otelcol/config.yaml
	sudo cp otelcol.env /usr/local/etc/otelcol/otelcol.env

	sudo mkdir -p /var/log/otelcol
	sudo cp newsyslog.conf /etc/newsyslog.d/otelcol.conf

	sudo cp com.github.open-telemetry.opentelemetry-collector.plist /Library/LaunchDaemons/
	sudo chmod 644 /Library/LaunchDaemons/com.github.open-telemetry.opentelemetry-collector.plist
	sudo chown root:wheel /Library/LaunchDaemons/com.github.open-telemetry.opentelemetry-collector.plist
	sudo launchctl unload /Library/LaunchDaemons/com.github.open-telemetry.opentelemetry-collector.plist
	sudo launchctl load -w /Library/LaunchDaemons/com.github.open-telemetry.opentelemetry-collector.plist

.PHOMY: lint
lint: lint-gha lint-otelcol lint-renovate ## codeをlintする
	shellcheck *.sh
	plutil -lint com.github.open-telemetry.opentelemetry-collector.plist

lint-gha:
	npx prettier -c .github/workflows/*.yaml
	yamllint .github/workflows/
	actionlint
	zizmor .
	ghalint run

lint-otelcol:
	yamllint builder-config.yaml otelcol-config.yaml
	MACKEREL_APIKEY='dummy' otelcol/otelcol validate --config otelcol-config.yaml

lint-renovate:
	npx --package renovate@latest -- renovate-config-validator
	yamllint .github/dependabot.yml

status: ## OpenTelemetry Collector serviceの稼働狀態を見る
	sudo launchctl list | grep opentelemetry-collector
	sudo lsof -iTCP:4317,4318 || true
	tail -f /var/log/otelcol/stdout.log
