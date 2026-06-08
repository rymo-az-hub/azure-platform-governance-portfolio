# Azure Platform Governance Portfolio

このリポジトリは、中堅規模の組織を想定した **Azure Governance / Policy Baseline** の設計・実装例です。

Azureリソースを作るだけではなく、権限、Policy、Tag、Log、Cost、例外運用、Evidenceをどう管理するかを整理します。AVD運用標準化は、CloudOpsの考え方を実運用へ落としたサブテーマとして扱います。

## 関連ポートフォリオ

このリポジトリは、Azure基盤の統制・標準化を主題にしたポートフォリオです。Microsoft 365、Microsoft Entra ID、Microsoft Intune、Azure Virtual Desktop、AD DS、Microsoft Entra Cloud Syncを横断したCloudOps / Hybrid Identity寄りの検証は、以下の別リポジトリで扱っています。

| テーマ | リポジトリ | 主な観点 |
|---|---|---|
| Azure Governance / Policy Baseline | このリポジトリ | Azure Policy、RBAC、Tag、Log、Cost、例外運用、Evidence、Bicep |
| Microsoft 365 / AVD / AD DS / Cloud Sync | [m365-avd-ad-cloudsync-portfolio](https://github.com/rymo-az-hub/m365-avd-ad-cloudsync-portfolio) | Entra ID、Intune、AVD、AD DS、Cloud Sync、PHS、CloudOps Runbook |

## 現在の状態

初期PoCは完了済みです。

確認済みの内容は以下です。

| 項目 | 状態 |
|---|---|
| Bicep build | 完了 |
| What-If | 完了 |
| Deploy | 完了 |
| Validate | 完了 |
| Evidence反映 | 完了 |
| Teardown | 完了 |
| PoC実行用アカウント後片付け | 完了 |
| ローカル品質チェック | 完了 |

PoCでは、Owner常用ではなく、検証用の実行アカウントに必要なロールを事前付与して実行しました。検証後は、作成したResource Group、Policy Assignment、Policy Definition、実行用アカウントを削除済みです。

## 実装範囲

このリポジトリでは、実装済みの範囲、設計・文書化に留めている範囲、今後拡張する範囲を分けています。

| 区分 | 内容 |
|---|---|
| PoC実装済み | SubscriptionスコープBicep、Resource Group、Log Analytics Workspace、VNet、Custom Policy Definition、Policy Assignment、What-If、Deploy、Validate、Teardown |
| 設計・文書化済み | RBAC設計、Tag標準、Cost管理方針、例外運用、AVD運用標準化、ADR、Evidence方針 |
| 今後拡張 | Management Group展開、Policy Initiative、Policy Exemption、Diagnostic Settings本格実装、Budget、GitHub Actions |

初期PoCでは、Azure Governance Baselineの流れを小さく検証することを優先しています。そのため、すべての領域を本番運用レベルまで実装しているわけではありません。

## 想定シナリオ

Azure利用を広げる前に、Subscription単位で最低限の統制を整えるケースを想定しています。

初期版では、Enterprise Scale Landing Zone全体を再現するのではなく、低コストで検証しやすい範囲に絞ります。

## 主テーマ: Azure Governance / Policy Baseline

| 領域 | ドキュメント |
|---|---|
| 要件・前提 | `docs/01_main_azure_governance_baseline/requirements.md` |
| ガバナンス設計 | `docs/01_main_azure_governance_baseline/governance_design.md` |
| Policy設計 | `docs/01_main_azure_governance_baseline/policy_baseline.md` |
| RBAC設計 | `docs/01_main_azure_governance_baseline/rbac_design.md` |
| Tag標準 | `docs/01_main_azure_governance_baseline/tagging_standard.md` |
| 監視・ログ | `docs/01_main_azure_governance_baseline/monitoring_logging_design.md` |
| コスト管理 | `docs/01_main_azure_governance_baseline/cost_management_notes.md` |
| 例外運用 | `docs/01_main_azure_governance_baseline/exception_operation.md` |
| 検証計画 | `docs/01_main_azure_governance_baseline/validation_plan.md` |

## サブテーマ: AVD運用標準化

AVD運用標準化は、Azure基盤運用の実務適用例として配置しています。

ここではAVD全体設計や本番手順そのものではなく、棚卸し、事前確認、DryRun、結果出力、切り分け、顧客回答の考え方を整理しています。

| 領域 | ドキュメント |
|---|---|
| 全体設計 | `docs/02_sub_avd_operations_standardization/avd_ops_design.md` |
| 棚卸し・事前確認 | `docs/02_sub_avd_operations_standardization/inventory_and_precheck.md` |
| SessionHostライフサイクル | `docs/02_sub_avd_operations_standardization/sessionhost_lifecycle.md` |
| Personal Desktop割当 | `docs/02_sub_avd_operations_standardization/personal_desktop_assignment.md` |
| 接続不可時の切り分け | `docs/02_sub_avd_operations_standardization/troubleshooting_flow.md` |
| 作業チェックリスト | `docs/02_sub_avd_operations_standardization/operation_checklist.md` |
| 顧客回答テンプレート | `docs/02_sub_avd_operations_standardization/customer_response_template.md` |

## 実装

| 領域 | パス |
|---|---|
| Bicepエントリポイント | `infra/main.bicep` |
| Bicepパラメータ | `infra/parameters/` |
| Bicepモジュール | `infra/modules/` |
| Azure CLI Runbook | `scripts/cli/` |
| AVD運用スクリプト | `scripts/avd/` |
| ローカル品質チェック | `scripts/local/Test-RepositoryQuality.ps1` |

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

## 推奨確認順

1. `docs/00_overview/portfolio_scope.md`
2. `docs/00_overview/architecture_overview.md`
3. `docs/01_main_azure_governance_baseline/requirements.md`
4. `docs/01_main_azure_governance_baseline/governance_design.md`
5. `docs/01_main_azure_governance_baseline/policy_baseline.md`
6. `infra/main.bicep`
7. `scripts/cli/README.md`
8. `docs/04_evidence/06-validation-summary.md`
9. `docs/03_adr/README.md`
10. `docs/02_sub_avd_operations_standardization/avd_ops_design.md`

## 面接官向けの最短確認ルート

短時間で確認する場合は、以下の順番を想定しています。

1. `README.md` で全体像とPoC完了状態を確認
2. `docs/01_main_azure_governance_baseline/governance_design.md` で設計方針を確認
3. `infra/main.bicep` で実装範囲を確認
4. `scripts/cli/README.md` で実行手順を確認
5. `docs/04_evidence/06-validation-summary.md` で検証結果を確認

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
Evidence記録
  ↓
Teardown
  ↓
残存確認
```

検証結果は `docs/04_evidence/` に記録しています。

## ローカル品質チェック

PowerShell 7で以下を実行します。

```powershell
.\scripts\local\Test-RepositoryQuality.ps1
```

確認対象は、主要ファイルの存在、Bicep build、PowerShell構文、生成物の残存有無です。

## EvidenceとADR

- Evidence: `docs/04_evidence/`
- ADR: `docs/03_adr/`

Evidenceは公開用にマスクした検証サマリです。実Tenant ID、Subscription ID、Principal ID、UPN、顧客固有値は公開しません。必要な場合はサンプル値またはマスク値に置き換えます。
