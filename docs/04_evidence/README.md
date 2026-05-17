# Evidence

このディレクトリには、Azure Governance Baselineの検証結果を記録します。

Evidenceは、コマンド出力をそのまま貼る場所ではありません。何を確認し、どの結果になり、未確認項目が何かを後から追えるように整理して残します。

公開用Evidenceでは、実Tenant ID、Subscription ID、Principal ID、UPNなどはマスクします。

## ファイル一覧

| ファイル | 内容 |
|---|---|
| `01-what-if-result.md` | デプロイ前のWhat-If結果 |
| `02-deployment-result.md` | デプロイ結果と主要リソース確認 |
| `03-policy-assignment-result.md` | Azure Policy Assignment確認 |
| `04-rbac-validation-result.md` | RBAC Assignment確認 |
| `05-diagnostic-settings-result.md` | Log Analytics Workspace / VNetの確認。Diagnostic Settings詳細適用は将来拡張 |
| `06-validation-summary.md` | 検証結果のまとめ |

## 記録方針

Evidenceでは、以下を明確にします。

- いつ確認したか
- どのPublic review baselineまたは検証時点を対象にしたか
- どのRunbookまたはコマンドを使ったか
- 何を確認したか
- 結果はどうだったか
- 未確認項目は何か
- 次に必要な対応は何か

## 公開時の注意

以下はそのまま記載しません。

- 実Tenant ID
- 実Subscription ID
- 実Principal ID
- 実UPN
- 顧客名
- 社内システム名
- 実IPアドレス一覧
- 実環境のResource名

必要な場合は、`<subscription-id>` や `rg-workload-sample` のようなサンプル値に置き換えます。

## レビュー観点

- 実行対象が分かるか
- 検証結果が判断に使える粒度か
- 未確認項目が明記されているか
- 設計書、Runbook、ADRとつながっているか
- 機密情報が残っていないか

## Public review baseline

このEvidenceは、公開レビュー用に実行結果をマスク・整理したサマリです。

実Tenant ID、Subscription ID、Principal ID、UPN、顧客固有値、実環境固有値は公開しません。必要な値は `<subscription-id>`、`<tenant-id>`、`<poc-deployer-user>` などのマスク値に置き換えます。

各Evidenceの `Baseline` は、特定の旧commit IDではなく、公開用に整理した現行mainブランチ相当の検証ベースラインを示します。
