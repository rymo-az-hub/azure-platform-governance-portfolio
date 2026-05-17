# RBAC Validation Result

## 1. 目的

RBAC Assignmentの確認結果を記録します。

## 2. 実行情報

| 項目 | 内容 |
|---|---|
| 実行日 | 2026-05-17 |
| 実行者 | `<poc-deployer-user>` |
| 対象Subscription | `<subscription-name>` |
| 対象Scope | `/subscriptions/<subscription-id>` |
| Baseline | Public review baseline |

## 3. 確認コマンド

```powershell
.\scripts\cli\Test-GovernanceBaseline.ps1 `
  -Environment "sandbox" `
  -ResourceNamePrefix "apg"
```

## 4. RBAC確認結果

| Principal | Role | Scope | 結果 | 備考 |
|---|---|---|---|---|
| `<poc-deployer-user>` | Contributor | Subscription | OK | PoC実行用に事前付与 |
| `<poc-deployer-user>` | Resource Policy Contributor | Subscription | OK | Policy Definition / Assignment作成用に事前付与 |
| BicepによるRBAC Assignment | なし | なし | OK | `enableRbacAssignments = false` |

## 5. レビュー観点

| 確認項目 | 結果 | 備考 |
|---|---|---|
| Owner権限でPoCを実行していないか | OK | PoC用ユーザーで実行 |
| Bicepで不要なRBAC Assignmentを作成していないか | OK | 作成なし |
| 事前付与ロールがPoC用途に限定されているか | OK | Contributor / Resource Policy Contributor |
| 実Principal IDやUPNをEvidenceへ残していないか | OK | マスク値で記録 |
| PoC完了後に実行用ユーザーを削除したか | OK | 削除済み |
| PoC完了後にRole Assignmentが残っていないか | OK | principalId指定で残存なしを確認 |

## 6. 後片付け確認

PoC完了後、実行用ユーザーに付与したロールを削除し、ユーザー自体も削除しました。

対象ユーザーが残っていないことをAzure CLIで確認済みです。

また、削除済みユーザーのprincipalIdを条件にRole Assignmentを確認し、残存がないことを確認しました。

## 7. 判断

PoCはOwner常用ではなく、PoC用ユーザーに必要なロールを付与して実行しました。

初期PoCではBicepによるRBAC Assignmentを無効化しているため、新規のRole Assignmentは作成していません。

PoC完了後、実行用ユーザーとRole Assignmentの後片付けも完了しています。
