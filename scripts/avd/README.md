# AVD Operation Scripts

このディレクトリには、AVD運用標準化の考え方を示す公開用スクリプトを配置します。

実務で利用した確認観点と処理思想をベースにしていますが、公開用では環境固有値、顧客名、実UPN、実HostPool名、実Resource Group名は含めません。

## 目的

AVD運用で発生しやすい作業について、対象整理、事前確認、DryRun、結果出力の流れを再現しやすくします。

このディレクトリのスクリプトは、本番環境の正式手順をそのまま置き換えるものではありません。承認済み作業を安全に進めるための確認観点と、Runbook化の例を示すものです。

主な目的は以下です。

- 作業対象をCSVで明確にする
- 作業前確認を標準化する
- Active sessionがある対象を誤って処理しない
- 非Active sessionのサインアウト後に再確認する
- DryRunで実行予定を確認する
- SessionHost、VM、NIC、Managed Diskを段階的に扱う
- 削除要求後の完了確認を行う
- 最終残存確認を行う
- スキップ理由や処理結果をログとして残す

## スクリプト一覧

| Script | 用途 |
|---|---|
| `Export-AvdHostPoolInventory.ps1` | HostPool内のSessionHostと割当状態を棚卸しする |
| `Remove-AvdSessionHostResources.ps1` | SessionHost、VM、NIC、Managed Diskの段階削除と残存確認の流れを示す |
| `Set-AvdPersonalDesktopAssignment.ps1` | Personal Desktop割当作業における事前確認、DryRun、結果記録の考え方を示す |
| `Start-AzVmFromCsv.ps1` | CSV指定のVMを状態確認付きで起動する |

## サンプルCSV

| File | 用途 |
|---|---|
| `samples/avd-inventory-targets.sample.csv` | HostPool棚卸し対象 |
| `samples/remove-avd-sessionhost-targets.sample.csv` | SessionHost削除対象VM |
| `samples/personal-desktop-assignment.sample.csv` | Personal Desktop割当確認対象 |
| `samples/start-vm-targets.sample.csv` | VM起動対象 |

## Remove-AvdSessionHostResources.ps1 の位置づけ

`Remove-AvdSessionHostResources.ps1` は、AVD SessionHost削除時に発生しやすい関連リソースの残存を防ぐためのサンプルです。

主な流れは以下です。

1. CSVから対象VMを読み込む
2. HostPool上のSessionHostを特定する
3. Active sessionがある場合はスキップする
4. 非Active sessionをサインアウトする
5. セッション残存を再確認する
6. SessionHostを削除する
7. Azure VMを削除する
8. VM削除完了をポーリング確認する
9. VMに紐づいていたNICを削除する
10. VMに紐づいていたManaged Diskを削除する
11. SessionHost / VM / NIC / Diskの残存確認を行う
12. ログとSummaryを出力する

既定ではDryRunとして動作し、実変更する場合のみ `-Execute` を明示します。

## 実行例

DryRun:

~~~powershell
.\scripts\avd\Remove-AvdSessionHostResources.ps1 `
  -CsvPath ".\scripts\avd\samples\remove-avd-sessionhost-targets.sample.csv" `
  -AvdResourceGroupName "rg-avd-sample" `
  -HostPoolName "hp-avd-sample"
~~~

実行:

~~~powershell
.\scripts\avd\Remove-AvdSessionHostResources.ps1 `
  -CsvPath ".\scripts\avd\samples\remove-avd-sessionhost-targets.sample.csv" `
  -AvdResourceGroupName "rg-avd-sample" `
  -HostPoolName "hp-avd-sample" `
  -Execute
~~~

## 実行方針

- PowerShell 7.4以上を前提にする
- Azure PowerShellにログイン済みであることを前提にする
- 破壊的操作はDryRunを先に実行する
- `-Execute` を明示しない限り変更しない
- Active sessionがある対象はスキップする
- VM削除完了を確認してからNIC / Disk削除へ進む
- 結果は画面出力だけでなくログとして残す
- 実環境のTenant ID、Subscription ID、UPN、HostPool名は公開しない

## 注意点

このディレクトリのスクリプトは、承認フローや変更管理を代替するものではありません。

作業対象、実施可否、利用者影響、削除可否は、事前に承認または合意された前提で扱います。

本番環境でのAVD割当、削除、再構成は、公式ドキュメント、利用中の運用手順、変更管理、権限設計に従って実施する必要があります。

このスクリプトは、削除対象として承認済みのAVD SessionHost用VMを前提に、VMに紐づくNICとManaged Diskを段階的に扱うサンプルです。業務データを保持するData Disk、Backup、Lock、保護対象リソースがある場合は、事前確認と承認なしに削除しません。
