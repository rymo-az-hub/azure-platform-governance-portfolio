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
| Baseline | Public review baseline |
| Baseline ID | `public-review-v1` |
| Branch | `main` |

## 3. Evidenceの扱い

このValidation Summaryは、公開レビュー用に実行結果をマスク・整理したサマリです。

Baseline は、特定の旧commit IDではなく、公開用に整理した現行mainブランチ相当の検証ベースラインを示します。本Summaryでは `public-review-v1` を公開レビュー用の検証ベースラインとして扱います。実Tenant ID、Subscription ID、Principal ID、UPN、顧客固有値は公開しません。

## 4. 検証サマリー

| 領域 | 結果 | Evidence |
|---|---|---|
| What-If | OK | `01-what-if-result.md` |
| Deployment | OK | `02-deployment-result.md` |
| Policy Assignment | OK | `03-policy-assignment-result.md` |
| Policy state | OK | `03-policy-assignment-result.md` |
| RBAC | OK | `04-rbac-validation-result.md` |
| Log Analytics / VNet | OK | `05-monitoring-baseline-result.md` |
| Teardown | OK | 本文書に記録 |
| 実行用アカウント後片付け | OK | `04-rbac-validation-result.md` |

## 5. サニタイズ済み検証出力抜粋

以下は公開用にSubscription ID、Tenant ID、UPNをマスクした検証出力の抜粋です。

~~~text
Current Azure account
Subscription          SubscriptionId       TenantId       User
--------------------  -------------------  -------------  ----------------
<subscription-name>   <subscription-id>    <tenant-id>    <signed-in-user>

Resource groups
Name                            Location
------------------------------  ----------
rg-apg-sandbox-monitoring       japaneast
rg-apg-sandbox-network          japaneast
rg-apg-sandbox-workload-sample  japaneast

Cleanup validation succeeded. No teardown targets remain.
~~~

## 6. 受け入れ条件

| 確認項目 | 結果 | 備考 |
|---|---|---|
| Resource Groupが想定どおり作成されている | OK | `rg-apg-sandbox-*` 3件 |
| 必須Tagが付与されている | OK | Environment / Owner / CostCenter / Workload / ManagedBy |
| Log Analytics Workspaceが作成されている | OK | `law-apg-sandbox-monitoring` |
| VNetが作成されている | OK | `vnet-apg-sandbox-shared` |
| Policy Definitionが想定どおり作成されている | OK | 3件、Custom、Indexed |
| Policy Assignmentが想定どおり作成されている | OK | 7件、すべてAudit |
| Policy stateでPoC対象リソースが準拠している | OK | Workspace / VNet ともにCompliant |
| RBAC Assignmentが制御されている | OK | Bicepでは作成なし。PoC用ユーザーへ事前付与 |
| 検証後にリソースを削除できる | OK | Resource Group / Policy Assignment / Policy Definition削除済み |
| 検証後に実行用アカウントを削除できる | OK | User / Role Assignment ともに残存なし |
| Evidenceに機密情報が残っていない | OK | Subscription ID / Tenant ID / UPN等はマスク |

## 7. Teardown結果

以下を削除対象として確認し、削除を実行しました。

| 種別 | 結果 | 備考 |
|---|---|---|
| Resource Group | OK | `rg-apg-sandbox-*` 3件を削除要求済み |
| Policy Assignment | OK | `apg-sandbox-*` 7件を削除済み |
| Policy Definition | OK | `apg-sandbox-*` 3件を削除済み |
| 残存確認 | OK | 対象Resource Group / Policy Assignment / Policy Definitionは表示なし |
| 実行用アカウントの後片付け | OK | User / Role Assignment ともに残存なし |

## 8. 既知の制約

| 領域 | 制約 |
|---|---|
| Management Group | 初期PoCでは必須にしない。将来拡張候補として扱う |
| Monitoring baseline | 初期PoCではLog Analytics Workspace / VNetの作成確認まで。Diagnostic Settings詳細適用は将来拡張 |
| Alert | 詳細なAlert設計は対象外 |
| Sentinel | 初期PoCでは対象外 |
| PIM | 詳細設計は対象外 |
| 本番運用 | 初期PoCは検証環境を前提とする |

## 9. 判断

| 項目 | 内容 |
|---|---|
| Baselineを受け入れるか | 受け入れ可 |
| 必要な修正 | 初期PoCとしては必須修正なし |
| 次の対応 | READMEとEvidenceの最終整合確認 |

## 10. メモ

PoCはOwner常用ではなく、PoC用の実行アカウントにContributorとResource Policy Contributorを付与して実行しました。

初期PoCでは、Subscriptionスコープで軽量なGovernance Baselineを作成し、What-If、Deploy、Validate、Policy state確認、Teardownまで確認できました。

Policy AssignmentはSubscriptionスコープであるため、既存リソースも評価対象になります。PoC対象リソースはCompliantであり、既存リソースではTag不足によるNonCompliantも検出されました。初期PoCではDenyではなくAuditにより、既存運用を止めずに逸脱を可視化することを目的としています。

検証後、PoC用の実行アカウントとRole Assignmentの後片付けも完了しています。
