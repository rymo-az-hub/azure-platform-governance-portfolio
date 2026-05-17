# Personal Desktop Assignment Operation

## 1. 目的

この文書では、AVD Personal Desktop環境におけるAssignedUser割当作業の標準化方針を整理する。

AssignedUser割当は、単にSessionHostへユーザーを設定するだけの作業ではない。既存割当、重複割当、ユーザー存在、Desktop Application Groupの利用権限を確認しないと、割当後にユーザーが利用できない、または別ユーザーの利用環境を上書きする可能性がある。

そのため、割当前に必要な確認を行い、DryRun、実行、結果出力、作業後確認までを標準化する。

## 2. 対象作業

初期版では、以下を対象とする。

| 作業 | 内容 |
|---|---|
| 対象SessionHost確認 | 割当対象のSessionHostが存在するか確認する |
| 既存AssignedUser確認 | 既にユーザーが割り当てられていないか確認する |
| 重複割当確認 | 同一ユーザーが他SessionHostに割当済みでないか確認する |
| Entra ID存在確認 | 対象ユーザーが存在するか確認する |
| DAG権限確認 | ユーザーがDesktop Application Groupを利用できるか確認する |
| DryRun | 実変更前に割当予定とスキップ理由を確認する |
| AssignedUser設定 | 条件を満たす対象へ割当を実行する |
| 結果出力 | 成功、失敗、スキップ理由をCSVまたはログへ出力する |

## 3. 非対象範囲

以下は初期版では対象外とする。

| 項目 | 理由 |
|---|---|
| AVD全体設計 | 本文書は割当運用の標準化が対象 |
| ユーザーライフサイクル管理 | Entra ID側の入退社、異動、グループ運用は別設計 |
| FSLogixプロファイル移行 | ユーザーデータ影響が大きく、別手順が必要 |
| 本番環境固有の承認手順 | 公開用には一般化した考え方のみ記載する |
| 実UPNや実グループ名 | 公開リポジトリには含めない |

## 4. 基本方針

Personal Desktop割当では、以下を基本方針とする。

| 方針 | 内容 |
|---|---|
| 入力ファイルで対象を指定する | SessionHostとユーザーの対応を明確にする |
| 既存割当を確認する | 誤上書きを防ぐ |
| 重複割当を確認する | 同一ユーザーの複数割当を防ぐ |
| ユーザー存在を確認する | 存在しないユーザーへの割当を防ぐ |
| 利用権限を確認する | 割当後に利用できない状態を防ぐ |
| DryRunを先に実行する | 実行前に処理予定とスキップ理由を確認する |
| 結果を出力する | 作業結果をEvidenceとして残せるようにする |

## 5. 入力ファイル

公開版では、以下のようなサンプルCSVを想定する。

~~~csv
HostPoolResourceGroup,HostPoolName,SessionHostName,UserPrincipalName
rg-avd-sample,hp-avd-sample,avd-host-001.contoso.local,user001@example.com
rg-avd-sample,hp-avd-sample,avd-host-002.contoso.local,user002@example.com
~~~

実運用では、実UPN、実HostPool名、実SessionHost名を公開しない。公開リポジトリではサンプル値に置き換える。

## 6. 事前確認

割当前に確認する項目は以下。

| 確認項目 | 内容 | 問題がある場合の扱い |
|---|---|---|
| HostPool存在 | 指定HostPoolが存在するか | スキップ |
| SessionHost存在 | 指定SessionHostが存在するか | スキップ |
| 既存AssignedUser | 別ユーザーが割当済みでないか | 原則スキップ |
| 重複割当 | 同一ユーザーが他SessionHostに割当済みでないか | 原則スキップ |
| Entra IDユーザー | UPNのユーザーが存在するか | スキップ |
| DAG権限 | ユーザーが利用権限を持つか | 要確認またはスキップ |

既存AssignedUserが空でない場合、作業者判断で上書きしない。上書きが必要な場合は、依頼元または運用責任者の承認を前提とする。

## 7. DAG権限確認

Personal Desktopでは、AssignedUserを設定しても、Desktop Application Group側の権限がなければユーザーは利用できない。

そのため、割当対象ユーザーがDAGを利用できる状態か確認する。

確認観点は以下。

| 確認項目 | 内容 |
|---|---|
| 直接割当 | ユーザーにDesktop Virtualization Userが直接付与されているか |
| グループ割当 | ユーザーが割当済みグループに所属しているか |
| ネストグループ | 必要に応じてネストグループを確認する |
| 対象DAG | 割当先HostPoolに対応するDAGか |

DAG権限が不足している場合、AssignedUserだけ設定しても利用できない。作業結果としては失敗ではなく、前提不足として扱う。

## 8. DryRun

DryRunでは、実際の割当を行わず、以下を出力する。

| 項目 | 内容 |
|---|---|
| SessionHost | 対象SessionHost |
| TargetUser | 割当予定ユーザー |
| CurrentAssignedUser | 現在のAssignedUser |
| UserExists | Entra ID上の存在確認 |
| DagAccess | DAG利用権限の確認結果 |
| CanAssign | 割当可能か |
| SkipReason | スキップ理由 |

DryRunで確認し、問題がない対象のみ実行モードへ進む。

## 9. 実行結果

実行後は、以下をCSVまたはログとして出力する。

| 項目 | 内容 |
|---|---|
| SessionHost | 対象SessionHost |
| TargetUser | 割当対象ユーザー |
| PreviousAssignedUser | 実行前のAssignedUser |
| ResultAssignedUser | 実行後のAssignedUser |
| Result | Success / Failed / Skipped |
| Reason | 失敗またはスキップ理由 |
| StartedAt | 開始時刻 |
| FinishedAt | 終了時刻 |

結果出力は、作業後確認とEvidenceに利用する。

## 10. スキップ理由

スキップ理由は、後から確認できるよう具体的に残す。

代表例は以下。

| SkipReason | 内容 |
|---|---|
| HostPoolNotFound | HostPoolが存在しない |
| SessionHostNotFound | SessionHostが存在しない |
| AlreadyAssignedToAnotherUser | 別ユーザーが割当済み |
| UserAlreadyAssignedToAnotherHost | 同一ユーザーが別Hostへ割当済み |
| UserNotFound | Entra ID上にユーザーが存在しない |
| DagAccessNotConfirmed | DAG利用権限を確認できない |
| DryRunOnly | DryRunのため実行していない |

スキップは失敗ではない。作業条件を満たさない対象を安全に処理しなかった結果として扱う。

## 11. 作業後確認

割当後は、以下を確認する。

| 確認項目 | 内容 |
|---|---|
| AssignedUser | 対象SessionHostへ想定ユーザーが設定されているか |
| 重複割当 | 同一ユーザーが複数SessionHostへ割当されていないか |
| DAG権限 | 利用権限が不足していないか |
| 結果CSV | 成功、失敗、スキップが記録されているか |
| 顧客回答 | 必要に応じて確認結果を説明できるか |

## 12. スクリプトとの対応

この文書は、以下の公開用スクリプトと対応する。

| Script | 役割 |
|---|---|
| `Set-AvdPersonalDesktopAssignment.ps1` | AssignedUser割当の事前確認、DryRun、実行、結果出力を行う |
| `Export-AvdHostPoolInventory.ps1` | 割当前後の棚卸しに使う |

実務で作成した割当スクリプトの考え方を利用するが、公開版では環境依存値や実案件情報を除去する。

## 13. 責任分界

Personal Desktop割当では、以下を分けて考える。

| 領域 | 主な責任 |
|---|---|
| 割当対象の承認 | 依頼元または運用責任者 |
| 入力ファイルの作成 | 作業者または依頼元 |
| 事前確認 | 作業者 |
| DAG権限不足時の判断 | 運用責任者または依頼元 |
| スクリプト実行 | 作業者 |
| 結果確認 | 作業者とレビュー者 |

作業者は、承認されていない上書きや、権限不足を無視した割当を行わない。

## 14. まとめ

Personal DesktopのAssignedUser割当では、割当操作そのものよりも、事前確認と作業後確認が重要である。

既存割当、重複割当、Entra IDユーザー、DAG権限を確認し、DryRunと結果出力を用意することで、誤割当や利用不可状態を減らす。
