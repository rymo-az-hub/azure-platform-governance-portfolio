# SessionHost Lifecycle Operation

## 1. 目的

この文書では、AVD SessionHostの削除、整理、停止、起動に関する標準的な確認観点を整理します。

特に削除作業では、AVD上のSessionHostだけでなく、Azure VM、NIC、Managed Diskなどの関連リソースも確認する必要があります。確認が不足すると、利用者影響、削除漏れ、残存コストにつながります。

## 2. 対象作業

| 作業 | 内容 |
|---|---|
| SessionHost棚卸し | HostPool配下のSessionHost状態を確認する |
| Drain設定 | 新規接続を制御する |
| Active session確認 | 利用中ユーザーの有無を確認する |
| 非Active sessionのサインアウト | Activeではない残存セッションを整理する |
| SessionHost削除 | AVD管理上のSessionHostを削除する |
| VM削除 | 対応するAzure VMを削除する |
| VM削除完了確認 | 非同期削除後にVMが残っていないことを確認する |
| NIC削除 | VMに紐づいていたNICを削除する |
| Managed Disk削除 | VMに紐づいていたManaged Diskを削除する |
| 最終残存確認 | SessionHost / VM / NIC / Diskの残存を確認する |
| 起動 / 停止 | CSV指定のVM状態を確認して操作する |

## 3. 非対象範囲

| 項目 | 理由 |
|---|---|
| AVD HostPool設計 | 本文書は運用作業の標準化が対象 |
| イメージ更新設計 | ライフサイクル作業とは別管理にするため |
| FSLogixプロファイル操作 | 利用者データ影響が大きく、別手順が必要なため |
| Backup削除 | 保護設計と復旧要件に関わるため |
| Lock解除 | 管理者承認と変更管理が必要なため |
| 本番環境固有の承認手順 | 公開用には一般化した考え方のみ記載するため |

## 4. 基本方針

| 方針 | 内容 |
|---|---|
| 対象を明示する | CSVまたはパラメータで対象を指定する |
| 事前確認を行う | HostPool、SessionHost、VM、NIC、Diskを確認する |
| 利用者影響を避ける | Active sessionがある場合は原則スキップする |
| 非Active sessionを整理する | 必要に応じてサインアウトし、再確認する |
| DryRunを行う | 実行前に処理予定を確認する |
| 段階的に削除する | SessionHost、VM、NIC、Diskの順に処理する |
| 非同期削除を考慮する | VM削除完了を確認してから関連リソースを扱う |
| スキップ理由を残す | 処理しなかった対象の理由を記録する |
| 作業後確認を行う | HostPoolとAzureリソース側の残存を確認する |

## 5. 削除作業の標準フロー

~~~text
入力CSV確認
  ↓
HostPool / SessionHost存在確認
  ↓
AssignedUser / User session確認
  ↓
Active sessionがある場合はスキップ
  ↓
非Active sessionのサインアウト
  ↓
セッション再確認
  ↓
DryRun結果確認
  ↓
Drain設定
  ↓
SessionHost削除
  ↓
VM削除要求
  ↓
VM削除完了確認
  ↓
NIC削除
  ↓
Managed Disk削除
  ↓
SessionHost / VM / NIC / Disk残存確認
  ↓
結果出力
~~~

AVD管理上の削除とAzureリソース側の削除は、分けて確認します。

## 6. Active sessionの扱い

| Session状態 | 判断 |
|---|---|
| Active | 原則スキップ。依頼元または運用責任者へ確認 |
| Disconnected | サインアウト可否を確認して対応 |
| なし | 削除候補 |

作業者判断でActive sessionを切断しません。利用者影響があるため、事前合意または承認を前提にします。

## 7. Drain設定

削除またはメンテナンス対象のSessionHostでは、必要に応じてDrain設定を行います。

Drain設定は新規接続を抑止しますが、既存セッションは切断しません。そのため、Active session確認とセットで扱います。

## 8. 関連リソースの確認

SessionHostを削除しても、Azure VMや関連リソースが自動で削除されるとは限りません。

| リソース | 確認観点 |
|---|---|
| VM | 対象VMが正しいか、削除要求後に残存していないか |
| NIC | VMに紐づくNICか、VM削除後に削除可能か |
| OS Disk | 削除対象に含めるか |
| Data Disk | 業務データが含まれていないか |
| Public IP | 紐づきがないか、削除対象か |
| Backup | 保護状態が残っていないか |
| Lock | 削除を妨げるLockがないか |

この削除フローは、削除対象として承認済みのAVD SessionHost用VMを前提にします。業務データを保持するData Disk、Backup、Lock、保護対象リソースがある場合は、事前確認と承認なしに削除しません。

## 9. DryRunと実行結果

DryRunでは、実変更を行わず、対象、実行予定操作、現在状態、実行可否、スキップ理由を出力します。

実行後は、以下をログとして残します。

| 項目 | 内容 |
|---|---|
| RowNo | CSV上の対象行 |
| Phase | PRECHECK / SESSION / SESSIONHOST / VM / RESOURCE / FINAL |
| Target | 対象SessionHostまたはVM |
| Action | 実行した操作 |
| Result | Success / Error / Warning / Skip / DryRun |
| Detail | 失敗、警告、スキップ理由 |
| Summary | 処理件数の集計 |

## 10. 作業後確認

| 確認項目 | 内容 |
|---|---|
| HostPool | 対象SessionHostが残っていないか |
| VM | 対象VMが削除または想定状態になっているか |
| NIC | 不要なNICが残っていないか |
| Disk | 削除対象Diskが残っていないか |
| IP | 不要なPublic IPやIP割当が残っていないか |
| Backup / Lock | 不要な保護状態やLockが残っていないか |
| Cost | 不要リソースが残っていないか |

## 11. 関連スクリプト

| Script | 役割 |
|---|---|
| `Remove-AvdSessionHostResources.ps1` | SessionHost、VM、NIC、Managed Diskの段階削除と残存確認を行う |
| `Export-AvdHostPoolInventory.ps1` | 作業前後の棚卸しに使う |
| `Start-AzVmFromCsv.ps1` | VM起動作業を状態確認付きで行う |

## 12. まとめ

SessionHostライフサイクル作業では、削除や停止の実行そのものよりも、対象確認、利用者影響確認、関連リソース確認、作業後確認が重要です。

作業を段階化し、DryRunと結果出力を用意することで、削除漏れ、残存コスト、利用者影響を抑えます。
