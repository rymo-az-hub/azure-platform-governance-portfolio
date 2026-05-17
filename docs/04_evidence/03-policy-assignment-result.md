# Policy Assignment Result

## 1. 目的

この文書では、Azure Policy Assignmentの確認結果を記録します。

Policyが想定スコープへ割り当てられているか、初期効果が想定どおりかを確認します。

## 2. 実行情報

| 項目 | 内容 |
|---|---|
| 実行日 | YYYY-MM-DD |
| 実行者 | `<operator>` |
| 対象Subscription | `<subscription-name>` |
| 対象Scope | `<scope>` |
| Commit | `<commit-sha>` |

## 3. 確認コマンド

```powershell
az policy assignment list --scope <scope> --output table
az policy assignment show --name <assignment-name> --scope <scope>
```

## 4. 確認結果

| Policy | 期待する効果 | 結果 | 備考 |
|---|---|---|---|
| Require tag: Environment | Audit | 未確認 |  |
| Require tag: Owner | Audit | 未確認 |  |
| Require tag: CostCenter | Audit | 未確認 |  |
| Require tag: Workload | Audit | 未確認 |  |
| Require tag: ManagedBy | Audit | 未確認 |  |
| Allowed locations | Audit | 未確認 |  |
| Audit Public IP resources | Audit | 未確認 |  |

## 5. 出力抜粋

必要に応じて、Policy確認結果をマスクして貼り付けます。

```text
<policy assignment output>
```

## 6. 判断

| 項目 | 内容 |
|---|---|
| Policy Assignmentは想定どおりか | 未判断 |
| 保留事項 |  |
| 次の対応 |  |

## 7. 注意点

- 初期PoCではAudit中心で確認する
- Denyへ変更する場合は、影響範囲と例外運用を確認する
- Scopeが想定より広くなっていないか確認する
