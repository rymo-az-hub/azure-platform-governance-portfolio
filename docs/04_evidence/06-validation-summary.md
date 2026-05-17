# Validation Summary

## 1. 目的

Azure Governance BaselineのPoC検証結果をまとめます。

個別Evidenceの結果を集約し、初期PoCとして受け入れ可能か、追加対応が必要かを判断します。

## 2. 実行情報

| 項目 | 内容 |
|---|---|
| 検証日 | 2026-05-17 |
| 実行者 | `<poc-deployer-user>` |
| 対象Subscription | `<subscription-name>` |
| Parameter | `infra/parameters/lowcost-demo.bicepparam` |
| Commit | `915181d` |

## 3. 検証サマリー

| 領域 | 結果 | Evidence |
|---|---|---|
| What-If | OK | `01-what-if-result.md` |
| Deployment | OK | `02-deployment-result.md` |
| Policy Assignment | OK | `03-policy-assignment-result.md` |
| RBAC | OK | `04-rbac-validation-result.md` |
| Log Analytics / VNet | OK | `05-diagnostic-settings-result.md` |
| Teardown | OK | 本文書に記録 |

## 4. 受け入れ条件

| 確認項目 | 結果 | 備考 |
|---|---|---|
| Resource Groupが想定どおり作成されている | OK | `rg-apg-sandbox-*` 3件 |
| 必須Tagが付与されている | OK | Environment / Owner / CostCenter / Workload / ManagedBy |
| Log Analytics Workspaceが作成されている | OK | `law-apg-sandbox-monitoring` |
| VNetが作成されている | OK | `vnet-apg-sandbox-shared` |
| Policy Assignmentが想定どおり作成されている | OK | 7件、すべてAudit |
| RBAC Assignmentが制御されている | OK | Bicepでは作成なし。PoC用ユーザーへ事前付与 |
| 検証後にリソースを削除できる | OK | Resource Group / Policy Assignment / Policy Definition削除済み |
| Evidenceに機密情報が残っていない | OK | Subscription ID / Tenant ID / UPN等はマスク |

## 5. Teardown結果

以下を削除対象として確認し、削除を実行しました。

| 種別 | 結果 | 備考 |
|---|---|---|
| Resource Group | OK | `rg-apg-sandbox-*` 3件を削除要求済み |
| Policy Assignment | OK | `apg-sandbox-*` 7件を削除済み |
| Policy Definition | OK | `apg-sandbox-*` 3件を削除済み |
| 残存確認 | OK | 対象Resource Group / Policy Assignment / Policy Definitionは表示なし |

## 6. 既知の制約

| 領域 | 制約 |
|---|---|
| Management Group | 初期PoCでは必須にしない。将来拡張候補として扱う |
| Diagnostic Settings | 初期PoCではLog Analytics Workspace作成確認まで |
| Alert | 詳細なAlert設計は対象外 |
| Sentinel | 初期PoCでは対象外 |
| PIM | 詳細設計は対象外 |
| 本番運用 | 初期PoCは検証環境を前提とする |

## 7. 判断

| 項目 | 内容 |
|---|---|
| Baselineを受け入れるか | 受け入れ可 |
| 必要な修正 | 初期PoCとしては必須修正なし |
| 次の対応 | EvidenceとREADMEの整合確認、必要に応じてPoC手順を補足 |

## 8. メモ

PoCはOwner常用ではなく、PoC用ユーザーにContributorとResource Policy Contributorを付与して実行しました。

初期PoCでは、Subscriptionスコープで軽量なGovernance Baselineを作成し、What-If、Deploy、Validate、Teardownまで確認できました。
