# Azure CLI Runbook

このディレクトリには、Azure Governance BaselineのWhat-If、Deploy、Validate、Teardown、Teardown後残存確認に使うRunbookを配置します。

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
| `Invoke-Deploy.ps1` | What-If確認後に、明示確認付きでBicepデプロイを実行する |
| `Test-GovernanceBaseline.ps1` | デプロイ後の基本確認、Policy state、現在ユーザーのRole Assignment確認を実行する |
| `Invoke-Teardown.ps1` | 検証用Resource Group、Policy Assignment、Policy Definitionを削除する |
| `Test-TeardownCleanup.ps1` | Teardown後に対象Resource Group、Policy Assignment、Policy Definitionの残存確認を行う |

## 基本実行順

```powershell
.\scripts\cli\Set-AzContext.ps1 -SubscriptionId "<subscription-id>"

.\scripts\cli\Invoke-WhatIf.ps1 `
  -Location "japaneast" `
  -ParameterFile ".\infra\parameters\lowcost-demo.bicepparam"

.\scripts\cli\Invoke-Deploy.ps1 `
  -Location "japaneast" `
  -ParameterFile ".\infra\parameters\lowcost-demo.bicepparam" `
  -ConfirmDeploy

.\scripts\cli\Test-GovernanceBaseline.ps1 `
  -Environment "sandbox" `
  -ResourceNamePrefix "apg"

.\scripts\cli\Invoke-Teardown.ps1 `
  -Environment "sandbox" `
  -ResourceNamePrefix "apg" `
  -IncludePolicyCleanup `
  -ConfirmDelete

.\scripts\cli\Test-TeardownCleanup.ps1 `
  -Environment "sandbox" `
  -ResourceNamePrefix "apg"
```

`Invoke-Deploy.ps1` は `-ConfirmDeploy` を指定しない限り、実デプロイを実行しません。先に `Invoke-WhatIf.ps1` で差分を確認し、想定外の削除や変更がないことを確認した後にのみ `-ConfirmDeploy` を付けて実行します。

PowerShell標準の `-WhatIf` を併用した場合も、`az deployment sub create` は実行されません。

## 出力とマスク方針

`Set-AzContext.ps1` と `Test-GovernanceBaseline.ps1` は、既定ではSubscription ID、Tenant ID、User、Principal名などをマスクして出力します。

ローカル確認で実値が必要な場合のみ、`-ShowSensitive` を明示します。

```powershell
.\scripts\cli\Set-AzContext.ps1 -ShowSensitive
.\scripts\cli\Test-GovernanceBaseline.ps1 -ShowSensitive
```

公開Evidenceへ貼り付ける値は、原則としてマスク値を使用します。

## 運用方針

- Deploy前に `Invoke-WhatIf.ps1` を実行し、差分を確認する
- 差分確認後にのみ `Invoke-Deploy.ps1 -ConfirmDeploy` を使用する
- Deploy後にValidateを実行する
- Policy stateまで確認する
- 検証後はTeardownで不要リソースを削除する
- Teardown後は `Test-TeardownCleanup.ps1` で残存確認を行う
- Evidenceへ貼り付ける値は必要に応じてマスクする
- 実Tenant ID、Subscription ID、実ユーザー情報、実Principal IDはコミットしない

## 注意点

`Invoke-Teardown.ps1` は削除系操作を含みます。`-ConfirmDelete` を明示した場合のみ削除を実行します。

Policy AssignmentとPolicy Definitionも削除する場合は、`-IncludePolicyCleanup` を明示します。

このRunbookは、承認フローや変更管理を代替するものではありません。承認済みの検証作業を、再現しやすくするための補助として扱います。
