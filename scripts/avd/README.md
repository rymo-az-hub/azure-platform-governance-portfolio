# AVD Operation Scripts

このディレクトリには、AVD運用標準化の公開用スクリプトを配置します。

実務で利用した考え方をベースにしていますが、公開用では環境固有値、顧客名、実UPN、実HostPool名、実Resource Group名は含めません。

## 目的

AVD運用で発生しやすい定型作業を、事前確認、DryRun、実行、結果出力まで含めて再現しやすくします。

主な目的は以下です。

- 作業対象をCSVで明確にする
- 作業前確認を標準化する
- Active sessionや既存割当を確認する
- DryRunで実行予定を確認する
- スキップ理由を記録する
- 結果をCSVまたはログとして残す

## スクリプト一覧

| Script | 用途 |
|---|---|
| `Export-AvdHostPoolInventory.ps1` | HostPool内のSessionHost、AssignedUser、VM、NIC、Private IPを出力する |
| `Remove-AvdSessionHostResources.ps1` | SessionHost削除と関連Azureリソース確認を段階化する |
| `Set-AvdPersonalDesktopAssignment.ps1` | Personal DesktopのAssignedUser割当を確認付きで行う |
| `Start-AzVmFromCsv.ps1` | CSV指定のVMを状態確認付きで起動する |

## サンプルCSV

| File | 用途 |
|---|---|
| `samples/avd-inventory-targets.sample.csv` | HostPool棚卸し対象 |
| `samples/remove-avd-sessionhost-targets.sample.csv` | SessionHost削除対象 |
| `samples/personal-desktop-assignment.sample.csv` | Personal Desktop割当対象 |
| `samples/start-vm-targets.sample.csv` | VM起動対象 |

## 実行方針

- PowerShell 7.4以上を前提にする
- 破壊的操作はDryRunを先に実行する
- `-Execute` や `-ConfirmDelete` を明示しない限り変更しない
- 結果は画面出力だけでなくCSVとして残す
- 実環境のTenant ID、Subscription ID、UPN、HostPool名は公開しない

## 注意点

このディレクトリのスクリプトは、承認フローや変更管理を代替するものではありません。

作業対象、実施可否、利用者影響、削除可否は、事前に承認または合意された前提で扱います。
