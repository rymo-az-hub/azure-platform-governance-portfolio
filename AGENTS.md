# AGENTS.md

このリポジトリでAIエージェントを利用する際の共通指示です。
本書は Owner-led AI-assisted engineering baseline v1.0 に準拠します。

## 役割前提

- 最終判断、リスク受容、スコープ管理、公開判断、merge判断はProject Ownerが行います。
- AIは文書整理、レビュー、IaC草案、表現改善の補助であり、意思決定主体ではありません。
- AIの出力を判断の根拠として本文へ記載しないでください。判断はOwnerの判断として記述します。

## リポジトリの位置づけ

- Azure Governance / Policy BaselineのSubscriptionスコープPoCポートフォリオです。
- Azure Landing Zone全体の完全実装ではありません。実案件の本番設計ではなく、設計意図・検証・Evidence整理を示す公開用成果物です。

## 安全境界

- Azureへの実接続、`bicep deploy` / `az deployment` 系の実行、Policy / RBACの実適用、Teardownの実行は行わないでください。
- Bicep / IaCの変更は What-If / validation / review-first を前提とし、docs上でもこの前提を崩さないでください。
- RBACは最小権限を維持し、過剰なロール割り当て（Owner / Contributorの広域付与など）を提案・追加しないでください。
- Policyは Audit first の設計判断（ADR-002）を尊重し、明示指示なしにDeny化しないでください。
- 例外管理、監査、タグ標準、コスト統制の観点を設計から落とさないでください。

## Secrets / 非公開情報

- 実Tenant ID、実Subscription ID、実Subscription名、Object ID、UPN、実Resource Group名、実Principal、credential、connectionString、SAS URL、token類を記載しないでください。
- Evidenceは既存のplaceholder形式（`<subscription-id>` 等）とマスキング方針を維持してください。placeholderを実値らしい表現へ具体化しないでください。
- Azure組み込みロールの公開定義ID、ラボ用VNetのアドレス設計値（RFC1918）は記載可能です。

## 記述ルール

- 実施済みの検証（What-If / Deploy / Validate / Teardownの証跡）と、実務拡張時の追加設計領域（構想）を混同しないでください。
- 本番利用可能・商用利用可能と誤解される表現を避けてください。
- 誇大表現を使わず、落ち着いた自然な日本語の敬体で記述してください。
- 年齢、経験年数などの内部評価基準を本文へ記載しないでください。

## 明示指示なしに行わない操作

- ファイルの削除・移動・リネーム
- README・主要docs・ADRの章立てや意味の大幅変更
- Bicep / スクリプトの挙動変更
- GitHub Actions、Secrets、リポジトリ設定の変更

## 変更の進め方

- 変更は小さなPR単位で行い、目的を明確にしてください。
- 変更後に `git diff --check`、Markdownコードフェンス、リンク実在を確認してください。
- PRのmerge判断はProject Ownerが行います。
