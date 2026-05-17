# Deployment Result

## 1. 目的

Azure Governance Baselineのデプロイ結果を記録します。

## 2. 実行情報

| 項目 | 内容 |
|---|---|
| 実行日 | 2026-05-17 |
| 実行者 | `<poc-deployer-user>` |
| 対象Subscription | `<subscription-name>` |
| 対象Subscription ID | `<subscription-id>` |
| Template | `infra/main.bicep` |
| Parameter | `infra/parameters/lowcost-demo.bicepparam` |
| Location | `japaneast` |
| Commit | `915181d` |

## 3. 実行コマンド

```powershell
.\scripts\cli\Invoke-Deploy.ps1 `
  -Location "japaneast" `
  -ParameterFile ".\infra\parameters\lowcost-demo.bicepparam"
```

## 4. 確認結果

| 確認項目 | 結果 | 備考 |
|---|---|---|
| Deploymentが成功したか | OK | `Succeeded` |
| Resource Groupが想定どおり作成されたか | OK | `rg-apg-sandbox-*` 3件 |
| Log Analytics Workspaceが作成されたか | OK | `law-apg-sandbox-monitoring` |
| VNetが作成されたか | OK | `vnet-apg-sandbox-shared` |
| Policy Assignmentが作成されたか | OK | 7件 |
| Policy Definitionが作成されたか | OK | 3件 |
| RBAC Assignmentが作成されていないか | OK | `enableRbacAssignments = false` |

## 5. 出力要約

```text
provisioningState: Succeeded
mode: Incremental
outputs:
  monitoringResourceGroupName: rg-apg-sandbox-monitoring
  networkResourceGroupName: rg-apg-sandbox-network
  workloadResourceGroupName: rg-apg-sandbox-workload-sample
  logAnalyticsWorkspaceName: law-apg-sandbox-monitoring
  vnetName: vnet-apg-sandbox-shared
```

## 6. 判断

デプロイは成功しました。主要リソースも想定どおり作成されたため、Validateへ進めると判断しました。
