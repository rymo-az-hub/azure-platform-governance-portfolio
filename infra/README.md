# Infrastructure as Code

このディレクトリには、Azure Governance Baselineを構成するBicepテンプレートを配置します。

初期PoCでは、Subscriptionスコープで検証できる軽量な構成を扱います。本番向けLanding Zone全体を再現するのではなく、スコープ分離、パラメータ化、モジュール分割、検証手順を確認できることを重視します。

## 構成

```text
infra/
├─ main.bicep
├─ modules/
│  ├─ monitoring/
│  ├─ network/
│  ├─ policy/
│  ├─ rbac/
│  ├─ resource-groups/
│  └─ tagging/
└─ parameters/
   ├─ dev.bicepparam
   └─ lowcost-demo.bicepparam
```

## スコープ

初期PoCのエントリポイントはSubscriptionスコープです。

主な対象は以下です。

- Resource Group
- Log Analytics Workspace
- 最小ネットワーク構成
- Policy Assignment
- 任意のRBAC Assignment
- 共通Tag

Management Groupは初期PoCの必須要素にはしません。複数Subscriptionへ展開する段階で、Management GroupスコープのPolicy Assignmentや階層設計を検討します。

## パラメータ

| ファイル | 用途 |
|---|---|
| `parameters/dev.bicepparam` | 標準的な検証用パラメータ |
| `parameters/lowcost-demo.bicepparam` | 低コスト検証向けパラメータ |

パラメータファイルには、実Tenant ID、実Subscription ID、実UPN、実Principal ID、顧客名、社内環境名を含めません。

Log Analytics WorkspaceのPublic Network Accessは、初期PoCでは再現性を優先して明示的に `Enabled` とします。本番または閉域要件がある環境では、Private Link、ネットワーク経路、名前解決、運用者の接続方法を設計したうえで `Disabled` を検討します。

## Build

リポジトリ直下で実行します。

```powershell
az bicep build --file .\infra\main.bicep
```

生成されるJSONファイルは `.gitignore` で除外します。

## 実行の流れ

実行には `scripts/cli/` 配下のRunbookを使います。

```text
Azure CLI context確認
  ↓
What-If
  ↓
Deploy
  ↓
Validate
  ↓
Evidence記録
  ↓
不要リソース削除
```

## 設計メモ

- IaCはBicepを中心にする
- 操作と検証はAzure CLIを基本にする
- ローカル実行環境はPowerShell 7を想定する
- PolicyはAudit中心から始める
- RBAC AssignmentはPrincipalが指定された場合のみ扱う
- Log Analytics WorkspaceのPublic Network Accessはパラメータで明示する
- 検証後に削除できる構成にする

## レビュー観点

- Deployment Scopeが明確か
- モジュールの責務が分かれているか
- パラメータに実環境情報が含まれていないか
- 設計書の内容とBicepが対応しているか
- What-If、Deploy、Validate、Teardownの流れに乗せられるか
