# Codex向けリポジトリ運用メモ

このリポジトリはカスタム OpenTelemetry Collector のビルドと設定を管理してゐます。Codex で作業するときは次を守ってください。

## 基本方針

- 返答・コミットメッセージ・コメントはすべて日本語で書いてください。
- 既存設定を尊重し、ユーザーが手元で保持してゐる秘密情報 (Mackerel API key など) は **絶対に** ファイルへ書かないこと。
- ファイル編集は `apply_patch` を優先し、複数ファイルや大規模変更時のみ別手段を検討してください。
- コマンドは `/Users/ne-sachirou/dev/otelcol-config` を基準ディレクトリとして実行し、`cd` の代わりに `workdir` を指定してください (zsh の `cd` が独自拡張されてゐるため)。

## ビルドと検証

- Collector バイナリ生成: `make build-otelcol` (内部で `otelcol/` ディレクトリの Go コードをビルド)。
- コンポーネント更新: `make generate-otelcol-code` で `builder-config.yaml` に基づきコードを再生成できます。
- 設定検証: `MACKEREL_APIKEY='dummy' ./otelcol/otelcol validate --config=file:otelcol-config.yaml` のように **必ず** `MACKEREL_APIKEY` にダミー値 (例: `dummy`) を指定して実行してください。実際のキーが必要なケースや検証できない場合は、その理由を明記して報告します。
- Lint/静的チェック: `make lint` (YAML、GitHub Actions、Renovate、plist をまとめて検査)。

## 構成ファイルの注意点

- `otelcol-config.yaml` は Collector 本体の設定であり、`service.telemetry.metrics` など Collector 内部テレメトリの扱いもここに記述します。変更時は pipelines/receivers/exporters の整合性を再確認してください。
- `builder-config.yaml` を変更したら `make generate-otelcol-code` を必ず走らせ、`otelcol/components.go` など生成物の差分をコミット対象に含めます。
- plist や LaunchDaemon 設定 (`com.github.open-telemetry.opentelemetry-collector.plist*`) を弄る際は `plutil -lint` を忘れずに。

## テスト・デプロイ関連

- 実機への導入は `make install-otelcol` で行うが、sudo を多用するため基本的にユーザーの指示がない限り実行しない。
- サービス状態確認が必要な場合は `make status` を使い、4317/4318 ポートの占有やログも合わせて伝えてください。

## ドキュメント整理

- 変更点を報告するときはファイルパスと行番号 (例: `otelcol-config.yaml:52`) を添えて説明してください。
- 追加の運用手順や依存関係が判明したら、この `.codex/instructions.md` に追記して運用知識を蓄積します。
