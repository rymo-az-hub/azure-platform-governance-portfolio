# Inventory and Pre-check

## 1. 目的

この文書では、AVD運用作業を行う前に確認すべき棚卸し項目と事前確認の考え方を整理する。

AVD運用では、作業対象を正しく把握しないまま変更すると、利用者影響、誤操作、削除漏れ、権限不足による作業後トラブルにつながる。

そのため、作業前にHostPool、SessionHost、AssignedUser、VM、NIC、Private IP、接続状態、権限前提を確認し、作業対象と作業可否を明確にする。

## 2. 棚卸しの位置づけ

棚卸しは、単なる一覧取得ではない。

作業前に以下を判断するための材料である。

- 対象SessionHostが存在するか
- 対象VMが存在するか
- AssignedUserが想定どおりか
- Private IPやNICが想定どおりか
- Active sessionが残っていないか
- 作業対象外のリソースを含んでいないか
- 作業後に削除漏れや設定漏れを確認できるか

棚卸し結果は、作業対象の確定、顧客確認、作業前後比較、Evidenceに利用する。

## 3. 対象情報

AVD運用で確認する主な情報は以下。

| 区分 | 確認項目 | 用途 |
|---|---|---|
| HostPool | HostPool名 | 作業対象環境の確認 |
| SessionHost | SessionHost名 | 作業対象の確認 |
| SessionHost | AllowNewSession / Drain状態 | 接続制御状態の確認 |
| SessionHost | AssignedUser | Personal Desktop割当の確認 |
| Session | Active session | 利用者影響の確認 |
| VM | VM名 | Azureリソース側の確認 |
| VM | PowerState | 起動、停止、削除可否の判断 |
| NIC | NIC名 | 削除対象やIP確認 |
| IP | Private IP | 固定IP、接続先、顧客確認用 |
| DAG | Desktop Application Group | ユーザー利用権限の確認 |
| User | UPN | 割当対象ユーザーの確認 |

## 4. 作業前確認の基本方針

作業前確認では、以下を基本方針とする。

| 方針 | 内容 |
|---|---|
| 対象を入力ファイルで明示する | 作業対象を人の記憶や画面確認だけに依存しない |
| 取得結果をCSVに出す | 作業前後で比較できるようにする |
| 存在しない対象をスキップする | 存在確認できないものは処理しない |
| 利用中リソースを変更しない | Active sessionがある場合は原則スキップする |
| スキップ理由を記録する | なぜ処理しなかったか後から確認できるようにする |
| 実行前にDryRunする | 実変更前に対象と処理内容を確認する |

## 5. HostPool棚卸し

HostPool棚卸しでは、HostPoolを起点にSessionHost情報を取得する。

確認する内容は以下。

| 項目 | 内容 |
|---|---|
| HostPool名 | 対象HostPoolが正しいか |
| Resource Group | HostPoolの所属Resource Group |
| SessionHost名 | HostPool配下のSessionHost一覧 |
| AssignedUser | Personal Desktop割当ユーザー |
| AllowNewSession | 新規接続可否 |
| SessionHost状態 | Available、Unavailableなど |

この情報により、作業対象がHostPool上で認識されているかを確認する。

## 6. VM / NIC / IP確認

SessionHostはAVD上のオブジェクトであり、実体としてAzure VM、NIC、DiskなどのAzureリソースが存在する。

そのため、SessionHostだけでなく、Azureリソース側も確認する。

| 項目 | 内容 |
|---|---|
| VM名 | SessionHostに対応するVMか |
| VM Resource Group | 削除や起動対象のRGが正しいか |
| PowerState | 起動中、停止中、割り当て解除済みなど |
| NIC名 | VMに紐づくNICか |
| Private IP | 想定IPか |
| OS Disk / Data Disk | 削除対象に含めるか |

削除作業では、SessionHostだけ削除しても、VM、NIC、Diskが残る可能性がある。作業前に関連リソースを確認しておく。

## 7. AssignedUser確認

Personal Desktop環境では、AssignedUserの確認が重要になる。

確認する内容は以下。

| 項目 | 内容 |
|---|---|
| 対象ユーザー | UPNが正しいか |
| 既存割当 | 既に別ユーザーが割り当てられていないか |
| 重複割当 | 同一ユーザーが他SessionHostに割当済みでないか |
| Entra ID存在確認 | 対象ユーザーが存在するか |
| DAG権限 | Desktop Application Groupを利用できるか |

AssignedUserだけ設定しても、DAG側の利用権限が不足しているとユーザーは利用できない。割当作業では、AVD側の設定と利用権限の両方を確認する。

## 8. Active session確認

削除、停止、再起動、Drain設定変更など、利用者影響がある作業ではActive sessionを確認する。

| 状態 | 判断 |
|---|---|
| Active sessionあり | 原則スキップまたは依頼元へ確認 |
| Disconnected sessionのみ | ログオフ可否を確認してから対応 |
| Sessionなし | 作業可能候補 |

Active sessionがある状態で処理を進めると、利用中ユーザーへ影響が出る。スクリプトでは、Active sessionがある対象を自動でスキップする設計にする。

## 9. DryRun

DryRunでは、実際の変更を行わず、以下を出力する。

- 処理対象
- 実行予定操作
- スキップ対象
- スキップ理由
- 確認が必要な対象

DryRun結果を確認してから実行モードへ進む。

DryRunで確認すべき点は以下。

| 確認項目 | 内容 |
|---|---|
| 対象が想定どおりか | 余計なSessionHostやVMが含まれていないか |
| スキップ理由が妥当か | Active session、存在なし、権限不足など |
| 削除対象が過不足ないか | VM、NIC、Diskなど |
| 利用者影響がないか | Active sessionやAssignedUserを確認 |

## 10. Evidence

棚卸しと事前確認の結果は、Evidenceとして残す。

想定するEvidenceは以下。

| Evidence | 内容 |
|---|---|
| Inventory CSV | HostPool、SessionHost、VM、NIC、IP、AssignedUser一覧 |
| Pre-check result | 作業可否、スキップ理由、確認事項 |
| DryRun result | 実行予定操作、対象、スキップ対象 |
| Execution result | 実行結果、成功、失敗、スキップ |
| Post-check result | 作業後の残存確認 |

公開リポジトリでは、実環境のCSVをそのまま置かない。サンプルCSVを使う。

## 11. サンプル入力ファイル

公開版では、以下のようなサンプル入力を想定する。

~~~csv
HostPoolResourceGroup,HostPoolName,SessionHostName,ExpectedAssignedUser
rg-avd-sample,hp-avd-sample,avd-host-001.contoso.local,user001@example.com
rg-avd-sample,hp-avd-sample,avd-host-002.contoso.local,user002@example.com
~~~

実運用では、顧客名、実UPN、実HostPool名、実IPアドレスを含むCSVを公開しない。

## 12. スクリプトとの対応

棚卸しと事前確認は、以下のスクリプトと対応する。

| Script | 役割 |
|---|---|
| `Export-AvdHostPoolInventory.ps1` | HostPool起点でSessionHost、AssignedUser、VM、NIC、Private IPを出力する |
| `Remove-AvdSessionHostResources.ps1` | 削除前にActive sessionや関連リソースを確認する |
| `Set-AvdPersonalDesktopAssignment.ps1` | AssignedUserとDAG権限を確認する |
| `Start-AzVmFromCsv.ps1` | VM存在確認とPowerState確認を行う |

## 13. まとめ

AVD運用では、作業そのものよりも、作業前に対象と状態を正しく確認することが重要である。

棚卸し、Active session確認、AssignedUser確認、VM / NIC / IP確認、DryRunを組み合わせることで、作業者依存を減らし、利用者影響や作業漏れを抑える。
