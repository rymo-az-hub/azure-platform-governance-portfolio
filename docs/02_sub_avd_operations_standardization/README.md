# AVD Operations Standardization

このディレクトリでは、Azure Virtual Desktop運用における確認観点と標準化例を整理します。

AVDは本リポジトリの主テーマではありません。Azure Governance / Policy Baselineで整理した考え方を、実運用へ適用したサブテーマとして扱います。

## 位置づけ

ここで扱うのは、AVD全体アーキテクチャの設計や、本番環境の正式手順そのものではありません。

日常運用で発生しやすい作業について、作業対象の明確化、事前確認、DryRun、実行結果、スキップ理由、残存確認、接続不可時の切り分け、顧客回答の考え方を整理します。

## ドキュメント一覧

| ドキュメント | 内容 |
|---|---|
| `avd_ops_design.md` | AVD運用標準化の全体方針 |
| `inventory_and_precheck.md` | 棚卸しと作業前確認 |
| `sessionhost_lifecycle.md` | SessionHost、VM、NIC、Managed Diskの段階削除と残存確認 |
| `personal_desktop_assignment.md` | AssignedUser割当作業における確認観点 |
| `troubleshooting_flow.md` | 接続不可時の切り分け |
| `operation_checklist.md` | 作業前・作業中・作業後のチェックリスト |
| `customer_response_template.md` | 顧客・依頼元向け回答テンプレート |

## 関連スクリプト

公開用スクリプトは `scripts/avd/` に配置します。

| Script | 用途 |
|---|---|
| `Export-AvdHostPoolInventory.ps1` | HostPoolとSessionHostの棚卸し |
| `Remove-AvdSessionHostResources.ps1` | SessionHost、VM、NIC、Managed Diskの段階削除と残存確認 |
| `Set-AvdPersonalDesktopAssignment.ps1` | Personal Desktop割当作業における事前確認、DryRun、結果記録の例 |
| `Start-AzVmFromCsv.ps1` | CSV指定VMの状態確認と起動 |

## Remove-AvdSessionHostResources.ps1 の概要

`Remove-AvdSessionHostResources.ps1` は、AVD SessionHost削除時に発生しやすい関連リソースの残存を防ぐための公開用サンプルです。

主な流れは以下です。

1. CSVで対象VMを指定する
2. HostPool上のSessionHostを特定する
3. Active sessionがある対象はスキップする
4. 非Active sessionをサインアウトし、セッション残存を再確認する
5. SessionHostを削除する
6. Azure VMを削除する
7. VM削除完了をポーリング確認する
8. VMに紐づいていたNICとManaged Diskを削除する
9. SessionHost / VM / NIC / Diskの残存確認を行う
10. ログとSummaryを出力する

このスクリプトは、削除対象として承認済みのAVD SessionHost用VMを前提にします。業務データを保持するData Disk、Backup、Lock、保護対象リソースがある場合は、事前確認と承認なしに削除しません。

## 設計方針

- 作業対象をCSVまたはパラメータで明確にする
- 実行前に状態を確認する
- 破壊的操作はDryRunを先に行う
- `-Execute` を明示しない限り変更しない
- Active sessionがある対象はスキップする
- 非Active sessionの処理後に再確認する
- VM削除完了を確認してからNIC / Disk削除へ進む
- スキップ理由を記録する
- 結果をログとして残す
- スクリプトは承認フローや変更管理を代替しない

## 注意点

本ディレクトリの内容は、公開用に一般化した運用標準化例です。

本番環境でのAVD割当、削除、再構成は、公式ドキュメント、利用中の運用手順、変更管理、権限設計に従って実施する必要があります。

## レビュー観点

- 作業対象と前提条件が明確か
- 利用者影響を確認できるか
- DryRunと実行モードが分離されているか
- 実行結果をEvidenceとして残せるか
- 関連リソースの残存確認ができるか
- 顧客回答で、確認済み事実と未確認範囲を分けているか
