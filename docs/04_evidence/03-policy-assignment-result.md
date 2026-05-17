# Policy Assignment Result

## 1. 目的

Azure Policy Assignmentの確認結果を記録します。

## 2. 実行情報

| 項目 | 内容 |
|---|---|
| 実行日 | 2026-05-17 |
| 実行者 | `<poc-deployer-user>` |
| 対象Subscription | `<subscription-name>` |
| 対象Scope | `/subscriptions/<subscription-id>` |
| Commit | `915181d` |

## 3. 確認コマンド

```powershell
.\scripts\cli\Test-GovernanceBaseline.ps1 `
  -Environment "sandbox" `
  -ResourceNamePrefix "apg"
```

## 4. 確認結果

| Policy | 期待する効果 | 結果 | 備考 |
|---|---|---|---|
| Require tag: Environment | Audit | OK | `apg-sandbox-require-environment` |
| Require tag: Owner | Audit | OK | `apg-sandbox-require-owner` |
| Require tag: CostCenter | Audit | OK | `apg-sandbox-require-costcenter` |
| Require tag: Workload | Audit | OK | `apg-sandbox-require-workload` |
| Require tag: ManagedBy | Audit | OK | `apg-sandbox-require-managedby` |
| Allowed locations | Audit | OK | `apg-sandbox-allowed-locations` |
| Audit Public IP resources | Audit | OK | `apg-sandbox-audit-public-ip` |

## 5. 判断

Policy Assignmentは想定どおりSubscriptionスコープに作成されました。

初期PoCではすべてAuditであり、Denyは使用していません。
