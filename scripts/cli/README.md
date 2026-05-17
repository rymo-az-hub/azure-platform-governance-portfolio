# Azure CLI Runbook

このディレクトリには、Azure Governance BaselineのWhat-If、Deploy、Validate、Teardownに使うRunbookを配置します。

操作はAzure CLIを基本とし、Windows + PowerShell 7環境から `az` コマンドを呼び出します。

## 前提

- PowerShell 7.4以上
- Azure CLI
- Bicep CLI
- Git
- 対象Subscriptionへの操作権限
- リポジトリ直下からの実行

## スクリプト一覧

| Script | 用途 |
|---|---|
| `Set-AzContext.ps1` | Azure CLIログイン状態とSubscriptionを確認・設定する |
| `Invoke-WhatIf.ps1` | BicepのWhat-Ifを実行する |
| `Invoke-Deploy.ps1` | Bicepデプロイを実行する |
| `Test-GovernanceBaseline.ps1` | デプロイ後の基本確認を実行する |
| `Invoke-Teardown.ps1` | 検証用Resource Groupを削除する |

## 基本実行順

```powershell
.\scripts\cli\Set-AzContext.ps1 -SubscriptionId "<subscription-id>"

.\scripts\cli\Invoke-WhatIf.ps1 `
  -Location "japaneast" `
  -ParameterFile ".\infra\parameters\dev.bicepparam"

.\scripts\cli\Invoke-Deploy.ps1 `
  -Location "japaneast" `
  -ParameterFile ".\infra\parameters\dev.bicepparam"

.\scripts\cli\Test-GovernanceBaseline.ps1

.\scripts\cli\Invoke-Teardown.ps1 `
  -Environment "dev" `
  -ResourceNamePrefix "apg" `
  -ConfirmDelete
```

## 運用方針

- Deploy前にWhat-Ifを実行する
- Deploy後にValidateを実行する
- 検証後はTeardownで不要リソースを削除する
- Evidenceへ貼り付ける値は必要に応じてマスクする
- 実Tenant ID、Subscription ID、実ユーザー情報はコミットしない

## 注意点

`Invoke-Teardown.ps1` は削除系操作を含みます。`-ConfirmDelete` を明示した場合のみ削除を実行します。

このRunbookは、承認フローや変更管理を代替するものではありません。承認済みの検証作業を、再現しやすくするための補助として扱います。
