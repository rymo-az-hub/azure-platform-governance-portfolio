# RBAC Validation Result

## 1. 目的

この文書では、RBAC Assignmentの確認結果を記録します。

想定したPrincipalに、想定したRoleが、想定したScopeで付与されているかを確認します。

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
az role assignment list --scope <scope> --output table
az role assignment list --assignee <principal-id> --all --output table
```

## 4. RBAC確認結果

| Principal | Role | Scope | 結果 | 備考 |
|---|---|---|---|---|
| `<principal>` | Reader | Subscription | 未確認 | 初期版では無効化されている場合あり |

## 5. レビュー観点

| 確認項目 | 結果 | 備考 |
|---|---|---|
| 不要なOwner Assignmentがないか | 未確認 |  |
| 不要なContributor Assignmentがないか | 未確認 |  |
| グループ単位で付与されているか | 未確認 |  |
| Scopeが広すぎないか | 未確認 |  |
| 一時権限が残っていないか | 未確認 |  |

## 6. 出力抜粋

必要に応じて、RBAC確認結果をマスクして貼り付けます。

```text
<rbac output>
```

## 7. 判断

| 項目 | 内容 |
|---|---|
| RBAC Assignmentは想定どおりか | 未判断 |
| 保留事項 |  |
| 次の対応 |  |

## 8. 注意点

- 実Principal ID、Object ID、UPNはそのまま残さない
- Subscription全体のOwner / Contributorは特に確認する
- 初期PoCでRBAC Assignmentを無効化している場合は、その理由を記録する
