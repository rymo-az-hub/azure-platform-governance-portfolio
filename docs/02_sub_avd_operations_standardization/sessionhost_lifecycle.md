# SessionHost Lifecycle Operation

## 1. 目的

この文書では、AVD SessionHostのライフサイクル作業を標準化するための考え方を整理する。

対象は、SessionHostの削除、整理、停止、起動、作業前後確認である。

特に削除作業では、AVD上のSessionHostだけでなく、Azure VM、NIC、Diskなどの関連リソースも確認する必要がある。確認が不足すると、利用者影響、削除漏れ、残存コスト、後続調査の負荷につながる。

## 2. 対象作業

初期版では、以下の作業を対象とする。

| 作業 | 内容 |
|---|---|
| SessionHost棚卸し | HostPool配下のSessionHost状態を確認する |
| Drain設定 | 新規接続を制御する |
| Active session確認 | 利用中ユーザーの有無を確認する |
| SessionHost削除 | AVD管理上のSessionHostを削除する |
| VM削除 | 対応するAzure VMを削除する |
| NIC / Disk確認 | 関連リソースの残存を確認する |
| 起動 / 停止 | CSV指定のVM状態を確認して操作する |
| 作業後確認 | HostPoolとAzureリソース側の状態を確認する |

## 3. 非対象範囲

以下は初期版では対象外とする。

| 項目 | 理由 |
|---|---|
| AVDホストプール設計 | 本文書は運用作業の標準化が対象 |
| イメージ更新設計 | ライフサイクル作業とは別管理にする |
| FSLogixプロファイル操作 | 利用者データ影響が大きく、別設計が必要 |
| 本番環境固有の承認手順 | 公開用には一般化した考え方のみ記載する |
| 顧客固有の削除条件 | 実案件情報を含めないため対象外 |

## 4. 基本方針

SessionHostライフサイクル作業では、以下を基本方針とする。

| 方針 | 内容 |
|---|---|
| 対象を明示する | CSVまたはパラメータで対象を指定する |
| 事前確認を行う | HostPool、SessionHost、VM、NIC、Diskを確認する |
| 利用者影響を避ける | Active sessionがある場合は原則スキップする |
| DryRunを行う | 実行前に処理予定を確認する |
| 段階的に削除する | SessionHost、VM、NIC、Diskを順に確認する |
| スキップ理由を残す | 処理しなかった対象の理由を記録する |
| 作業後確認を行う | HostPoolとAzureリソース側の残存を確認する |

## 5. 削除作業の標準フロー

SessionHost削除は、以下の流れで扱う。

~~~text
入力ファイル確認
  ↓
HostPool / SessionHost存在確認
  ↓
AssignedUser確認
  ↓
Active session確認
  ↓
Drain設定
  ↓
Disconnected sessionの扱い確認
  ↓
DryRun結果確認
  ↓
SessionHost削除
  ↓
VM削除
  ↓
NIC / Disk確認
  ↓
残存リソース確認
  ↓
結果出力
~~~

この流れにより、AVD管理上の削除とAzureリソース側の削除を分けて確認できる。

## 6. Active sessionの扱い

Active sessionがある場合は、原則として削除対象からスキップする。

| Session状態 | 判断 |
|---|---|
| Active | 原則スキップ。依頼元または運用責任者へ確認 |
| Disconnected | ログオフ可否を確認して対応 |
| なし | 削除候補 |

作業者判断でActive sessionを切断しない。利用者影響があるため、事前合意または承認が必要になる。

## 7. Drain設定

削除またはメンテナンス対象のSessionHostでは、必要に応じてDrain設定を行う。

Drain設定により、新規接続を抑止し、既存セッションの整理を進めやすくする。

ただし、Drain設定だけでは既存セッションは切断されない。そのため、Active session確認とセットで扱う。

## 8. VM / NIC / Disk削除の考え方

SessionHostを削除しても、Azure VMや関連リソースが自動で削除されるとは限らない。

削除対象として確認するものは以下。

| リソース | 確認観点 |
|---|---|
| VM | 対象VMが正しいか。PowerStateはどうか |
| NIC | VMに紐づくNICか。Private IPは想定どおりか |
| OS Disk | 削除対象に含めるか |
| Data Disk | 業務データが含まれていないか |
| Public IP | 紐づきがないか。削除対象か |
| Backup | 保護状態が残っていないか |
| Lock | 削除を妨げるLockがないか |

特にDiskとBackupは、削除前に扱いを確認する。作業者判断で削除してよいものではない。

## 9. DryRun出力

DryRunでは、実変更を行わず、以下を出力する。

| 項目 | 内容 |
|---|---|
| Target | 対象SessionHostまたはVM |
| Action | 実行予定操作 |
| CurrentState | 現在の状態 |
| CanExecute | 実行可能か |
| SkipReason | スキップ理由 |
| Notes | 追加確認事項 |

DryRun結果をレビューしてから実行モードへ進む。

## 10. 実行結果

実行結果はCSVまたはログとして残す。

想定する出力項目は以下。

| 項目 | 内容 |
|---|---|
| Target | 対象SessionHostまたはVM |
| Action | 実行した操作 |
| Result | Success / Failed / Skipped |
| Reason | 失敗またはスキップ理由 |
| StartedAt | 開始時刻 |
| FinishedAt | 終了時刻 |
| Operator | 実行者 |

結果出力は、作業後確認とEvidenceに利用する。

## 11. 作業後確認

作業後には、以下を確認する。

| 確認項目 | 内容 |
|---|---|
| HostPool | 対象SessionHostが残っていないか |
| VM | 対象VMが削除または想定状態になっているか |
| NIC | 不要なNICが残っていないか |
| Disk | 削除対象Diskが残っていないか |
| IP | 不要なPublic IPやPrivate IP割当が残っていないか |
| Backup | 不要な保護状態が残っていないか |
| Cost | 不要リソースが残っていないか |

作業後確認を行わない場合、削除漏れや残存コストに気付きにくい。

## 12. スクリプトとの対応

この文書は、以下の公開用スクリプトと対応する。

| Script | 役割 |
|---|---|
| `Remove-AvdSessionHostResources.ps1` | SessionHost削除と関連リソース確認を段階化する |
| `Export-AvdHostPoolInventory.ps1` | 作業前後の棚卸しに使う |
| `Start-AzVmFromCsv.ps1` | VM起動作業を状態確認付きで行う |

実務スクリプトの考え方を利用するが、公開版では固有名詞や環境依存値を除去し、汎用化する。

## 13. 責任分界

SessionHostライフサイクル作業では、以下を分けて考える。

| 領域 | 主な責任 |
|---|---|
| 削除対象の承認 | 依頼元または運用責任者 |
| 作業前確認 | 作業者 |
| 利用者影響判断 | 運用責任者または依頼元との合意 |
| スクリプト実行 | 作業者 |
| 結果確認 | 作業者とレビュー者 |
| 例外判断 | 承認者 |

スクリプトは判断を代替しない。承認済みの対象に対して、確認漏れを減らすために使う。

## 14. まとめ

SessionHostライフサイクル作業では、削除や停止の実行そのものよりも、対象確認、利用者影響確認、関連リソース確認、作業後確認が重要である。

作業を段階化し、DryRunと結果出力を用意することで、作業者依存を減らし、削除漏れや利用者影響を抑える。
