# Azure Platform Governance Portfolio

このリポジトリは、中堅規模の組織を想定した **Azure Governance / Policy Baseline** の設計・実装例です。

Azureリソースを作るだけではなく、権限、Policy、Tag、Log、Cost、例外運用、Evidenceをどう管理するかを整理します。AVD運用標準化は、CloudOpsの考え方を実運用へ落としたサブテーマとして扱います。

このリポジトリは、Azure Landing Zone全体の完全実装ではありません。初期PoCでは、低コストで再現しやすい **Subscription単位のGovernance Baseline** に範囲を絞っています。

## 3分で確認する場合

短時間で見る場合は、以下の順番を想定しています。

| 順番 | 見るもの | 確認できること |
|---:|---|---|
| 1 | [README](README.md) | 全体像、PoC完了状態、実装範囲 |
| 2 | [Governance Design](docs/01_main_azure_governance_baseline/governance_design.md) | 統制方針、責任分界、例外運用 |
| 3 | [Bicep entry point](infra/main.bicep) | 実装対象とスコープ |
| 4 | [CLI Runbook](scripts/cli/README.md) | What-If、Deploy、Validate、Teardownの流れ |
| 5 | [Validation Summary](docs/04_evidence/06-validation-summary.md) | 検証結果、Policy state、Teardown、後片付け |

## 15分で確認する場合

設計から実装、Evidenceまで追う場合は、以下の順番が読みやすいです。

| 順番 | 見るもの | 確認できること |
|---:|---|---|
| 1 | [Portfolio Scope](docs/00_overview/portfolio_scope.md) | 対象範囲と非対象範囲 |
| 2 | [Architecture Overview](docs/00_overview/architecture_overview.md) | 全体構成と設計単位 |
| 3 | [Requirements](docs/01_main_azure_governance_baseline/requirements.md) | 要件、前提、制約 |
| 4 | [Governance Design](docs/01_main_azure_governance_baseline/governance_design.md) | ガバナンス設計 |
| 5 | [Policy Baseline](docs/01_main_azure_governance_baseline/policy_baseline.md) | Policy設計とAudit first方針 |
| 6 | [RBAC Design](docs/01_main_azure_governance_baseline/rbac_design.md) | 権限設計とPoC実行権限 |
| 7 | [Bicep entry point](infra/main.bicep) | Subscriptionスコープ実装 |
| 8 | [CLI Runbook](scripts/cli/README.md) | 実行手順 |
| 9 | [Validation Summary](docs/04_evidence/06-validation-summary.md) | 検証結果 |
| 10 | [ADR](docs/03_adr/README.md) | 設計判断の記録 |
| 11 | [AVD Operations](docs/02_sub_avd_operations_standardization/README.md) | CloudOps実務適用例 |

## 現在の状態

初期PoCは完了済みです。

確認済みの内容は以下です。

| 項目 | 状態 |
|---|---|
| Bicep build | 完了 |
| What-If | 完了 |
| Deploy | 完了 |
| Validate | 完了 |
| Policy state確認 | 完了 |
| Evidence反映 | 完了 |
| Teardown | 完了 |
| PoC実行用アカウント後片付け | 完了 |
| ローカル品質チェック | 完了 |

PoCでは、Owner常用ではなく、検証用の実行アカウントに必要なロールを事前付与して実行しました。検証後は、作成したResource Group、Policy Assignment、Policy Definition、実行用アカウントを削除済みです。

## 実装範囲

このリポジトリでは、実装済みの範囲、設計・文書化に留めている範囲、今後拡張する範囲を分けています。

| 区分 | 内容 |
|---|---|
| PoC実装済み | SubscriptionスコープBicep、Resource Group、Log Analytics Workspace、VNet、Custom Policy Definition、Policy Assignment、What-If、Deploy、Validate、Policy state確認、Teardown |
| 設計・文書化済み | RBAC設計、Tag標準、Cost管理方針、例外運用、Monitoring方針、AVD運用標準化、ADR、Evidence方針 |
| 今後拡張 | Management Group展開、Policy Initiative、Policy Exemption、Diagnostic Settings本格実装、Budget、GitHub Actions |

初期PoCでは、Azure Governance Baselineの流れを小さく検証することを優先しています。そのため、すべての領域を本番運用レベルまで実装しているわけではありません。

## 想定シナリオ

Azure利用を広げる前に、Subscription単位で最低限の統制を整えるケースを想定しています。

初期版では、Enterprise Scale Landing Zone全体を再現するのではなく、低コストで検証しやすい範囲に絞ります。

## 主テーマ: Azure Governance / Policy Baseline

| 領域 | ドキュメント |
|---|---|
| 要件・前提 | [requirements.md](docs/01_main_azure_governance_baseline/requirements.md) |
| ガバナンス設計 | [governance_design.md](docs/01_main_azure_governance_baseline/governance_design.md) |
| Policy設計 | [policy_baseline.md](docs/01_main_azure_governance_baseline/policy_baseline.md) |
| RBAC設計 | [rbac_design.md](docs/01_main_azure_governance_baseline/rbac_design.md) |
| Tag標準 | [tagging_standard.md](docs/01_main_azure_governance_baseline/tagging_standard.md) |
| 監視・ログ | [monitoring_logging_design.md](docs/01_main_azure_governance_baseline/monitoring_logging_design.md) |
| コスト管理 | [cost_management_notes.md](docs/01_main_azure_governance_baseline/cost_management_notes.md) |
| 例外運用 | [exception_operation.md](docs/01_main_azure_governance_baseline/exception_operation.md) |
| 検証計画 | [validation_plan.md](docs/01_main_azure_governance_baseline/validation_plan.md) |

## サブテーマ: AVD運用標準化

AVD運用標準化は、Azure基盤運用の実務適用例として配置しています。

ここではAVD全体設計や本番手順そのものではなく、棚卸し、事前確認、DryRun、結果出力、関連リソースの残存確認、接続不可時の切り分け、顧客回答の考え方を整理しています。

特に `Remove-AvdSessionHostResources.ps1` では、AVD SessionHost、Azure VM、NIC、Managed Diskを段階的に扱うRunbook例を示しています。Active sessionがある対象はスキップし、非Active sessionの整理、VM削除完了確認、関連リソース削除、最終残存確認までを扱います。

| 領域 | ドキュメント |
|---|---|
| 全体設計 | [avd_ops_design.md](docs/02_sub_avd_operations_standardization/avd_ops_design.md) |
| 棚卸し・事前確認 | [inventory_and_precheck.md](docs/02_sub_avd_operations_standardization/inventory_and_precheck.md) |
| SessionHostライフサイクル | [sessionhost_lifecycle.md](docs/02_sub_avd_operations_standardization/sessionhost_lifecycle.md) |
| Personal Desktop割当 | [personal_desktop_assignment.md](docs/02_sub_avd_operations_standardization/personal_desktop_assignment.md) |
| 接続不可時の切り分け | [troubleshooting_flow.md](docs/02_sub_avd_operations_standardization/troubleshooting_flow.md) |
| 作業チェックリスト | [operation_checklist.md](docs/02_sub_avd_operations_standardization/operation_checklist.md) |
| 顧客回答テンプレート | [customer_response_template.md](docs/02_sub_avd_operations_standardization/customer_response_template.md) |

## 実装

| 領域 | パス |
|---|---|
| Bicepエントリポイント | [infra/main.bicep](infra/main.bicep) |
| Bicepパラメータ | [infra/parameters/](infra/parameters/) |
| Bicepモジュール | [infra/modules/](infra/modules/) |
| Azure CLI Runbook | [scripts/cli/](scripts/cli/) |
| AVD運用スクリプト | [scripts/avd/](scripts/avd/) |
| ローカル品質チェック | [scripts/local/Test-RepositoryQuality.ps1](scripts/local/Test-RepositoryQuality.ps1) |

## 構成

```text
.
├─ docs/
│  ├─ 00_overview/
│  ├─ 01_main_azure_governance_baseline/
│  ├─ 02_sub_avd_operations_standardization/
│  ├─ 03_adr/
│  └─ 04_evidence/
├─ infra/
│  ├─ main.bicep
│  ├─ modules/
│  └─ parameters/
└─ scripts/
   ├─ cli/
   ├─ avd/
   └─ local/
```

## 検証済みの流れ

```text
設計確認
  ↓
Bicep build
  ↓
What-If
  ↓
Deploy
  ↓
Policy / RBAC / Tag / Log の確認
  ↓
Policy state確認
  ↓
Evidence記録
  ↓
Teardown
  ↓
残存確認
  ↓
PoC実行用アカウント後片付け
```

検証結果は [docs/04_evidence/](docs/04_evidence/) に記録しています。

## ローカル品質チェック

PowerShell 7で以下を実行します。

```powershell
.\scripts\local\Test-RepositoryQuality.ps1
```

確認対象は、主要ファイルの存在、Bicep build、PowerShell構文、生成物の残存有無です。

## EvidenceとADR

| 種別 | パス |
|---|---|
| Evidence | [docs/04_evidence/](docs/04_evidence/) |
| ADR | [docs/03_adr/](docs/03_adr/) |

Evidenceは公開用にマスクした検証サマリです。実Tenant ID、Subscription ID、Principal ID、UPN、顧客固有値は公開しません。必要な場合はサンプル値またはマスク値に置き換えます。
