# AVD Operations Standardization

このディレクトリでは、Azure Virtual Desktop運用の標準化例を整理します。

AVDは本リポジトリの主テーマではありません。Azure Governance / Policy Baselineで整理した考え方を、実運用へ適用したサブテーマとして扱います。

## 位置づけ

ここで扱うのは、AVD全体アーキテクチャの設計ではなく、日常運用で発生しやすい作業の標準化です。

具体的には、作業対象の明確化、事前確認、DryRun、実行結果出力、スキップ理由、接続不可時の切り分け、顧客回答を整理します。

## ドキュメント一覧

| ドキュメント | 内容 |
|---|---|
| `avd_ops_design.md` | AVD運用標準化の全体方針 |
| `inventory_and_precheck.md` | 棚卸しと作業前確認 |
| `sessionhost_lifecycle.md` | SessionHost削除・整理・関連リソース確認 |
| `personal_desktop_assignment.md` | AssignedUser割当の確認と実行方針 |
| `troubleshooting_flow.md` | 接続不可時の切り分け |
| `operation_checklist.md` | 作業前・作業中・作業後のチェックリスト |
| `customer_response_template.md` | 顧客・依頼元向け回答テンプレート |

## 関連スクリプト

公開用スクリプトは `scripts/avd/` に配置します。

| Script | 用途 |
|---|---|
| `Export-AvdHostPoolInventory.ps1` | HostPoolとSessionHostの棚卸し |
| `Remove-AvdSessionHostResources.ps1` | SessionHost削除と関連リソース確認 |
| `Set-AvdPersonalDesktopAssignment.ps1` | Personal DesktopのAssignedUser割当 |
| `Start-AzVmFromCsv.ps1` | CSV指定VMの状態確認と起動 |

## 設計方針

- 作業対象をCSVまたはパラメータで明確にする
- 実行前に状態を確認する
- 破壊的操作はDryRunを先に行う
- Active sessionなど利用者影響を確認する
- スキップ理由を記録する
- 結果をCSVまたはログとして残す
- スクリプトは承認フローや変更管理を代替しない

## レビュー観点

- 作業対象と前提条件が明確か
- 利用者影響を確認できるか
- DryRunと実行モードが分離されているか
- 実行結果をEvidenceとして残せるか
- 顧客回答で、確認済み事実と未確認範囲を分けているか
