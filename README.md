# Azure Platform Governance Portfolio

このリポジトリは、中堅規模の組織を想定した **Azure Governance / Policy Baseline** の設計・実装例です。

Azureリソースを作るだけではなく、権限、Policy、Tag、Log、Cost、例外運用、Evidenceをどう管理するかを整理します。AVD運用標準化は、CloudOpsの考え方を実運用へ落としたサブテーマとして扱います。

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

実Tenant ID、Subscription ID、Principal ID、UPN、顧客固有値は公開しません。必要な場合はサンプル値またはマスク値に置き換えます。
