# Deployment Result

## 1. 目的

この文書では、Azure Governance Baselineのデプロイ結果を記録します。

デプロイが成功したかだけでなく、主要リソースが想定どおり作成されたかを確認します。

## 2. 実行情報

| 項目 | 内容 |
|---|---|
| 実行日 | YYYY-MM-DD |
| 実行者 | `<operator>` |
| 対象Subscription | `<subscription-name>` |
| 対象Subscription ID | `<subscription-id>` |
| Template | `infra/main.bicep` |
| Parameter | `infra/parameters/dev.bicepparam` |
| Location | `japaneast` |
| Commit | `<commit-sha>` |

## 3. 実行コマンド

```powershell
.\scripts\cli\Invoke-Deploy.ps1 `
  -Location "japaneast" `
  -ParameterFile ".\infra\parameters\dev.bicepparam"
```

## 4. 確認結果

| 確認項目 | 結果 | 備考 |
|---|---|---|
| Deploymentが成功したか | 未確認 |  |
| Resource Groupが想定どおり作成されたか | 未確認 |  |
| Log Analytics Workspaceが作成されたか | 未確認 |  |
| Policy Assignmentが作成されたか | 未確認 |  |
| RBAC Assignmentが想定どおりか | 未確認 | 初期版では無効化されている場合あり |
| Tagが付与されているか | 未確認 |  |

## 5. 出力抜粋

必要に応じて、デプロイ出力をマスクして貼り付けます。

```text
<deployment output>
```

## 6. 判断

| 項目 | 内容 |
|---|---|
| デプロイ結果 | 未判断 |
| 保留事項 |  |
| 次の対応 |  |

## 7. 注意点

- 実Subscription ID、Principal ID、UPNはそのまま残さない
- エラーが発生した場合は、失敗箇所と再実行可否を記録する
- デプロイ後は必ずValidateとTeardown確認を行う
