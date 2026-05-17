# Policy Assignment Result

## 1. 目的

Azure Policy AssignmentとPolicy stateの確認結果を記録します。

## 2. 実行情報

| 項目 | 内容 |
|---|---|
| 実行日 | 2026-05-17 |
| 実行者 | `<poc-deployer-user>` |
| 対象Subscription | `<subscription-name>` |
| 対象Scope | `/subscriptions/<subscription-id>` |
| Commit | `e4fe2f7` |

## 3. 確認コマンド

```powershell
.\scripts\cli\Test-GovernanceBaseline.ps1 `
  -Environment "sandbox" `
  -ResourceNamePrefix "apg"
```

Policy stateは、PoC対象リソースに絞って以下のように確認しました。

```powershell
$namePrefix = "apg-sandbox"

az policy state list `
  --query "[?contains(policyAssignmentName, '$namePrefix') && contains(resourceId, '/resourcegroups/rg-apg-sandbox')].{assignment:policyAssignmentName,resource:resourceId,state:complianceState}" `
  --output table
```

## 4. Policy Assignment確認結果

| Policy | 期待する効果 | 結果 | 備考 |
|---|---|---|---|
| Require tag: Environment | Audit | OK | `apg-sandbox-require-environment` |
| Require tag: Owner | Audit | OK | `apg-sandbox-require-owner` |
| Require tag: CostCenter | Audit | OK | `apg-sandbox-require-costcenter` |
| Require tag: Workload | Audit | OK | `apg-sandbox-require-workload` |
| Require tag: ManagedBy | Audit | OK | `apg-sandbox-require-managedby` |
| Allowed locations | Audit | OK | `apg-sandbox-allowed-locations` |
| Audit Public IP resources | Audit | OK | `apg-sandbox-audit-public-ip` |

## 5. Policy Definition確認結果

| Policy Definition | 種別 | Mode | 結果 |
|---|---|---|---|
| `apg-sandbox-require-tag` | Custom | Indexed | OK |
| `apg-sandbox-allowed-locations` | Custom | Indexed | OK |
| `apg-sandbox-audit-public-ip` | Custom | Indexed | OK |

## 6. Policy state確認結果

PoCで作成した主要リソースに絞ってPolicy stateを確認しました。

| 対象 | Policy state | 備考 |
|---|---|---|
| `law-apg-sandbox-monitoring` | Compliant | Location / 必須Tagに準拠 |
| `vnet-apg-sandbox-shared` | Compliant | Location / 必須Tagに準拠 |

SubscriptionスコープのPolicy Assignmentであるため、既存リソースも評価対象になります。既存リソースではTag不足によるNonCompliantも検出されましたが、初期PoCではAuditにより既存運用を止めずに逸脱を可視化することを目的としています。

## 7. 判断

Policy Assignmentは想定どおりSubscriptionスコープに作成されました。

初期PoCではすべてAuditであり、Denyは使用していません。

また、PoC対象リソースについてはPolicy stateでもCompliantであることを確認しました。
