# Diagnostic Settings Result

## 1. 目的

この文書では、Log Analytics WorkspaceとDiagnostic Settingsの確認結果を記録します。

ログ出力先が作成されているか、対象リソースのDiagnostic Settingsが想定どおりかを確認します。

## 2. 実行情報

| 項目 | 内容 |
|---|---|
| 実行日 | YYYY-MM-DD |
| 実行者 | `<operator>` |
| 対象Subscription | `<subscription-name>` |
| 対象Resource Group | `<resource-group-name>` |
| Commit | `<commit-sha>` |

## 3. 確認コマンド

```powershell
az monitor log-analytics workspace show `
  --resource-group <resource-group-name> `
  --workspace-name <workspace-name>

az monitor diagnostic-settings list `
  --resource <resource-id>
```

## 4. Log Analytics Workspace確認結果

| 確認項目 | 結果 | 備考 |
|---|---|---|
| Workspace名 | 未確認 |  |
| Resource Group | 未確認 |  |
| Location | 未確認 |  |
| SKU | 未確認 |  |
| Retention | 未確認 |  |
| Tag | 未確認 |  |

## 5. Diagnostic Settings確認結果

| Resource | Setting | Destination | 結果 | 備考 |
|---|---|---|---|---|
| `<resource-name>` | 未確認 | Log Analytics Workspace | 未確認 |  |

## 6. 出力抜粋

必要に応じて、確認結果をマスクして貼り付けます。

```text
<diagnostic settings output>
```

## 7. 判断

| 項目 | 内容 |
|---|---|
| Log Analytics Workspaceは想定どおりか | 未判断 |
| Diagnostic Settingsは想定どおりか | 未判断 |
| 保留事項 |  |
| 次の対応 |  |

## 8. 注意点

- 実Resource IDや実Subscription IDはそのまま残さない
- 収集対象ログが過剰でないか確認する
- 初期PoCでは、必要なログから段階的に確認する
