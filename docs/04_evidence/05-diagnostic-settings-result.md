# Diagnostic Settings Result

## 1. 目的

Log Analytics WorkspaceとDiagnostic Settingsの確認結果を記録します。

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

## 4. Log Analytics Workspace確認結果

| 確認項目 | 結果 | 備考 |
|---|---|---|
| Workspace名 | OK | `law-apg-sandbox-monitoring` |
| Resource Group | OK | `rg-apg-sandbox-monitoring` |
| Location | OK | `japaneast` |
| SKU | OK | `PerGB2018` |
| Retention | OK | 30日 |
| Tag | OK | 必須Tag付与済み |

## 5. Diagnostic Settings確認結果

| Resource | Setting | Destination | 結果 | 備考 |
|---|---|---|---|---|
| Log Analytics Workspace | N/A | N/A | 対象外 | 初期PoCではWorkspace作成確認まで |

## 6. 補足確認

VNetも想定どおり作成されていることを確認しました。

| 確認項目 | 結果 | 備考 |
|---|---|---|
| VNet名 | OK | `vnet-apg-sandbox-shared` |
| Address space | OK | `10.10.0.0/16` |
| Subnet | OK | `snet-shared` |
| Tag | OK | 必須Tag付与済み |

## 7. 判断

Log Analytics Workspaceは想定どおり作成されました。

初期PoCではDiagnostic Settingsの詳細設定までは実装対象外とし、ログ出力先の作成確認までを完了条件とします。
