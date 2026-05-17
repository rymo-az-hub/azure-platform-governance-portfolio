# AVD Operation Scripts

このディレクトリには、AVD運用標準化の考え方を示す公開用スクリプトを配置します。

実務で利用した確認観点をベースにしていますが、公開用では環境固有値、顧客名、実UPN、実HostPool名、実Resource Group名は含めません。

## 目的

AVD運用で発生しやすい作業について、対象整理、事前確認、DryRun、結果出力の流れを再現しやすくします。

このディレクトリのスクリプトは、本番環境の正式手順をそのまま置き換えるものではありません。承認済み作業を安全に進めるための確認観点と、Runbook化の例を示すものです。

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
| `Export-AvdHostPoolInventory.ps1` | HostPool内のSessionHostと割当状態を棚卸しする |
| `Remove-AvdSessionHostResources.ps1` | SessionHost削除前の確認、DryRun、関連リソース確認の流れを示す |
| `Set-AvdPersonalDesktopAssignment.ps1` | Personal Desktop割当作業における事前確認、DryRun、結果記録の考え方を示す |
| `Start-AzVmFromCsv.ps1` | CSV指定のVMを状態確認付きで起動する |

## サンプルCSV

| File | 用途 |
|---|---|
| `samples/avd-inventory-targets.sample.csv` | HostPool棚卸し対象 |
| `samples/remove-avd-sessionhost-targets.sample.csv` | SessionHost削除対象 |
| `samples/personal-desktop-assignment.sample.csv` | Personal Desktop割当確認対象 |
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

本番環境でのAVD割当、削除、再構成は、公式ドキュメント、利用中の運用手順、変更管理、権限設計に従って実施する必要があります。
