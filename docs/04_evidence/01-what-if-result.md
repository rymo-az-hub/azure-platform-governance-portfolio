# What-If Result

## 1. 目的

Azure Governance Baselineのデプロイ前に実行したWhat-If結果を記録します。

## 2. 実行情報

| 項目 | 内容 |
|---|---|
| 実行日 | 2026-05-17 |
| 実行者 | `<poc-deployer-user>` |
| 対象Subscription | `<subscription-name>` |
| 対象Subscription ID | `<subscription-id>` |
| Tenant ID | `<tenant-id>` |
| Template | `infra/main.bicep` |
| Parameter | `infra/parameters/lowcost-demo.bicepparam` |
| Location | `japaneast` |
| Commit | `915181d` |

## 3. 実行コマンド

```powershell
.\scripts\cli\Invoke-WhatIf.ps1 `
  -Location "japaneast" `
  -ParameterFile ".\infra\parameters\lowcost-demo.bicepparam"
```

## 4. 確認結果

| 確認項目 | 結果 | 備考 |
|---|---|---|
| Resource Group作成予定 | OK | `rg-apg-sandbox-*` 3件 |
| Log Analytics Workspace作成予定 | OK | `law-apg-sandbox-monitoring` |
| VNet作成予定 | OK | `vnet-apg-sandbox-shared` |
| Policy Assignment作成予定 | OK | 7件 |
| Policy Definition作成予定 | OK | 3件 |
| RBAC Assignment作成予定 | OK | 作成対象なし |
| 想定外の削除 | OK | なし |
| 想定外の変更 | OK | なし |

## 5. 判断

What-If結果に想定外の削除や変更はなかったため、Deployへ進めると判断しました。
