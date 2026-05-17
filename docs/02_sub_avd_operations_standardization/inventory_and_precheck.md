# Inventory and Pre-check

## 1. 目的

この文書では、AVD運用作業前に確認する棚卸し項目と事前確認の考え方を整理します。

作業対象を正しく把握しないまま変更すると、利用者影響、誤操作、削除漏れ、権限不足による作業後トラブルにつながります。

## 2. 棚卸しの位置づけ

棚卸しは、単なる一覧取得ではありません。

作業前に以下を判断するための材料です。

- 対象SessionHostが存在するか
- 対象VMが存在するか
- AssignedUserが想定どおりか
- Private IPやNICが想定どおりか
- Active sessionが残っていないか
- 作業対象外のリソースを含んでいないか
- 作業後に削除漏れや設定漏れを確認できるか

棚卸し結果は、作業対象の確定、作業前後比較、Evidenceに利用します。

## 3. 対象情報

| 区分 | 確認項目 | 用途 |
|---|---|---|
| HostPool | HostPool名 | 作業対象環境の確認 |
| SessionHost | SessionHost名 | 作業対象の確認 |
| SessionHost | AllowNewSession / Drain状態 | 接続制御状態の確認 |
| SessionHost | AssignedUser | Personal Desktop割当の確認 |
| Session | Active session | 利用者影響の確認 |
| VM | VM名 / PowerState | Azureリソース側の確認 |
| NIC / IP | NIC名 / Private IP | 削除対象や接続先の確認 |
| DAG | Desktop Application Group | ユーザー利用権限の確認 |
| User | UPN | 割当対象ユーザーの確認 |

## 4. 作業前確認の方針

| 方針 | 内容 |
|---|---|
| 対象を入力ファイルで明示する | 画面確認や記憶だけに依存しない |
| 取得結果をCSVに出す | 作業前後で比較できるようにする |
| 存在しない対象をスキップする | 確認できないものは処理しない |
| 利用中リソースを変更しない | Active sessionがある場合は原則スキップする |
| スキップ理由を記録する | 後から処理しなかった理由を確認できるようにする |
| DryRunを先に行う | 実変更前に対象と処理内容を確認する |

## 5. HostPool棚卸し

HostPoolを起点に、SessionHostの状態を確認します。

| 項目 | 内容 |
|---|---|
| HostPool名 | 対象HostPoolが正しいか |
| Resource Group | HostPoolの所属Resource Group |
| SessionHost名 | HostPool配下のSessionHost一覧 |
| AssignedUser | Personal Desktop割当ユーザー |
| AllowNewSession | 新規接続可否 |
| SessionHost状態 | Available / Unavailableなど |

## 6. VM / NIC / IP確認

SessionHostはAVD上の管理オブジェクトであり、実体としてAzure VM、NIC、Diskなどが存在します。

| 項目 | 内容 |
|---|---|
| VM名 | SessionHostに対応するVMか |
| VM Resource Group | 削除や起動対象のResource Groupが正しいか |
| PowerState | 起動中、停止中、割り当て解除済みなど |
| NIC名 | VMに紐づくNICか |
| Private IP | 想定IPか |
| OS Disk / Data Disk | 削除対象に含めるか |

SessionHostだけ削除しても、VM、NIC、Diskが残る可能性があります。作業前に関連リソースを確認します。

## 7. AssignedUser確認

Personal Desktop環境では、AssignedUserの確認が重要です。

| 項目 | 内容 |
|---|---|
| 対象ユーザー | UPNが正しいか |
| 既存割当 | 既に別ユーザーが割り当てられていないか |
| 重複割当 | 同一ユーザーが他SessionHostに割当済みでないか |
| Entra ID存在確認 | 対象ユーザーが存在するか |
| DAG権限 | Desktop Application Groupを利用できるか |

AssignedUserだけ設定しても、DAG側の利用権限が不足しているとユーザーは利用できません。

## 8. Active session確認

削除、停止、再起動、Drain設定変更など、利用者影響がある作業ではActive sessionを確認します。

| 状態 | 判断 |
|---|---|
| Active sessionあり | 原則スキップまたは依頼元へ確認 |
| Disconnected sessionのみ | ログオフ可否を確認してから対応 |
| Sessionなし | 作業可能候補 |

## 9. DryRun

DryRunでは、実際の変更を行わず、以下を出力します。

- 処理対象
- 実行予定操作
- スキップ対象
- スキップ理由
- 追加確認が必要な対象

DryRun結果を確認してから実行モードへ進みます。

## 10. Evidence

棚卸しと事前確認の結果は、Evidenceとして残します。

| Evidence | 内容 |
|---|---|
| Inventory CSV | HostPool、SessionHost、VM、NIC、IP、AssignedUser一覧 |
| Pre-check result | 作業可否、スキップ理由、確認事項 |
| DryRun result | 実行予定操作、対象、スキップ対象 |
| Execution result | 実行結果、成功、失敗、スキップ |
| Post-check result | 作業後の残存確認 |

公開リポジトリでは、実環境のCSVは置かず、サンプルCSVを使います。

## 11. サンプル入力

```csv
HostPoolResourceGroup,HostPoolName,SessionHostName,ExpectedAssignedUser
rg-avd-sample,hp-avd-sample,avd-host-001.contoso.local,user001@example.com
rg-avd-sample,hp-avd-sample,avd-host-002.contoso.local,user002@example.com
```

## 12. 関連スクリプト

| Script | 役割 |
|---|---|
| `Export-AvdHostPoolInventory.ps1` | HostPool起点でSessionHost、AssignedUser、VM、NIC、Private IPを出力する |
| `Remove-AvdSessionHostResources.ps1` | 削除前にActive sessionや関連リソースを確認する |
| `Set-AvdPersonalDesktopAssignment.ps1` | AssignedUserとDAG権限を確認する |
| `Start-AzVmFromCsv.ps1` | VM存在確認とPowerState確認を行う |

## 13. まとめ

AVD運用では、作業そのものよりも、作業前に対象と状態を正しく確認することが重要です。

棚卸し、Active session確認、AssignedUser確認、VM / NIC / IP確認、DryRunを組み合わせることで、作業者依存と利用者影響を抑えます。
