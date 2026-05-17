# Validation Summary

## 1. 目的

この文書では、Azure Governance Baselineの検証結果をまとめます。

個別Evidenceの結果を集約し、初期PoCとして受け入れ可能か、追加対応が必要かを判断します。

## 2. 実行情報

| 項目 | 内容 |
|---|---|
| 検証日 | YYYY-MM-DD |
| 実行者 | `<operator>` |
| 対象Subscription | `<subscription-name>` |
| Parameter | `infra/parameters/dev.bicepparam` |
| Commit | `<commit-sha>` |

## 3. 検証サマリー

| 領域 | 結果 | Evidence |
|---|---|---|
| What-If | 未確認 | `01-what-if-result.md` |
| Deployment | 未確認 | `02-deployment-result.md` |
| Policy Assignment | 未確認 | `03-policy-assignment-result.md` |
| RBAC | 未確認 | `04-rbac-validation-result.md` |
| Diagnostic Settings | 未確認 | `05-diagnostic-settings-result.md` |
| Teardown | 未確認 | TBD |

## 4. 受け入れ条件

| 確認項目 | 結果 | 備考 |
|---|---|---|
| Resource Groupが想定どおり作成されている | 未確認 |  |
| 必須Tagが付与されている | 未確認 |  |
| Log Analytics Workspaceが作成されている | 未確認 |  |
| Policy Assignmentが想定どおり作成されている | 未確認 |  |
| RBAC Assignmentが制御されている | 未確認 | 初期版では無効化されている場合あり |
| 検証後にリソースを削除できる | 未確認 |  |
| Evidenceに機密情報が残っていない | 未確認 |  |

## 5. 既知の制約

| 領域 | 制約 |
|---|---|
| Management Group | 初期PoCでは必須にしない。将来拡張候補として扱う |
| Alert | 詳細なAlert設計は対象外 |
| Sentinel | 初期PoCでは対象外 |
| PIM | 詳細設計は対象外 |
| 本番運用 | 初期PoCは検証環境を前提とする |

## 6. 判断

| 項目 | 内容 |
|---|---|
| Baselineを受け入れるか | 未判断 |
| 必要な修正 | TBD |
| 次の対応 | TBD |

## 7. メモ

- 個別Evidenceの結果と矛盾がないか確認する
- 未確認項目を残す場合は理由を記録する
- 実Tenant ID、Subscription ID、Principal ID、UPNは記載しない
- Teardown結果も検証完了条件に含める
