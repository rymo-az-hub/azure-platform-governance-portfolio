# Monitoring Baseline Result

## 1. 目的

Log Analytics WorkspaceとVNetの作成結果を確認し、初期PoCにおける監視基盤の入口が用意できていることを記録します。

このEvidenceは、Diagnostic Settingsの詳細実装結果ではありません。初期PoCでは、ログ出力先となるLog Analytics Workspaceの作成確認までを対象とします。

## 2. 実行情報

| 項目 | 内容 |
|---|---|
| 実行日 | 2026-05-17 |
| 実行者 | `<poc-deployer-user>` |
| 対象Subscription | `<subscription-name>` |
| 対象Resource Group | `rg-apg-sandbox-monitoring` |
| Commit | `915181d` |

## 3. 確認コマンド

```powershell
.\scripts\cli\Test-GovernanceBaseline.ps1 `
  -Environment "sandbox" `
  -ResourceNamePrefix "apg"
```

VNetについては、以下の観点でも確認しました。

```powershell
az network vnet show `
  --resource-group "rg-apg-sandbox-network" `
  --name "vnet-apg-sandbox-shared" `
  --query "{name:name,location:location,addressSpace:addressSpace.addressPrefixes,subnets:subnets[].name,tags:tags}" `
  --output jsonc
```

## 4. Log Analytics Workspace確認結果

| 確認項目 | 結果 | 備考 |
|---|---|---|
| Workspace名 | OK | `law-apg-sandbox-monitoring` |
| Resource Group | OK | `rg-apg-sandbox-monitoring` |
| Location | OK | `japaneast` |
| SKU | OK | `PerGB2018` |
| Retention | OK | 30日 |
| Tag | OK | 必須Tag付与済み |

## 5. VNet確認結果

| 確認項目 | 結果 | 備考 |
|---|---|---|
| VNet名 | OK | `vnet-apg-sandbox-shared` |
| Location | OK | `japaneast` |
| Address space | OK | `10.10.0.0/16` |
| Subnet | OK | `snet-shared` |
| Tag | OK | 必須Tag付与済み |

## 6. Diagnostic Settingsの扱い

| 項目 | 結果 | 備考 |
|---|---|---|
| Diagnostic Settings詳細実装 | 対象外 | 初期PoCでは実装しない |
| ログ出力先Workspace作成 | OK | `law-apg-sandbox-monitoring` |
| 今後の拡張 | 要検討 | Activity Log、主要リソース、ログカテゴリ、コスト影響を整理して追加する |

## 7. 判断

初期PoCとして、ログ出力先となるLog Analytics Workspaceと、最小ネットワーク構成であるVNetは想定どおり作成されました。

Diagnostic Settingsの詳細設定は、対象リソース、ログカテゴリ、保持期間、コスト影響を整理したうえで、今後の拡張対象とします。
