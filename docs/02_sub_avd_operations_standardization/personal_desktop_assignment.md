# Personal Desktop Assignment Operation

## 1. 目的

この文書では、AVD Personal Desktop環境におけるAssignedUser割当作業の標準化方針を整理します。

AssignedUser割当は、SessionHostへユーザーを設定するだけの作業ではありません。既存割当、重複割当、ユーザー存在、DAG権限を確認しないと、割当後に利用できない、または別ユーザーの環境を上書きする可能性があります。

## 2. 対象作業

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

| 項目 | 理由 |
|---|---|
| AVD全体設計 | 本文書は割当運用の標準化が対象 |
| ユーザーライフサイクル管理 | Entra ID側の入退社、異動、グループ運用は別設計 |
| FSLogixプロファイル移行 | ユーザーデータ影響が大きく、別手順が必要 |
| 本番環境固有の承認手順 | 公開用には一般化した考え方のみ記載する |
| 実UPNや実グループ名 | 公開リポジトリには含めない |

## 4. 基本方針

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

公開版では、以下のようなサンプルCSVを想定します。

```csv
HostPoolResourceGroup,HostPoolName,SessionHostName,UserPrincipalName
rg-avd-sample,hp-avd-sample,avd-host-001.contoso.local,user001@example.com
rg-avd-sample,hp-avd-sample,avd-host-002.contoso.local,user002@example.com
```

実運用では、実UPN、実HostPool名、実SessionHost名を公開しません。

## 6. 事前確認

| 確認項目 | 内容 | 問題がある場合の扱い |
|---|---|---|
| HostPool存在 | 指定HostPoolが存在するか | スキップ |
| SessionHost存在 | 指定SessionHostが存在するか | スキップ |
| 既存AssignedUser | 別ユーザーが割当済みでないか | 原則スキップ |
| 重複割当 | 同一ユーザーが他SessionHostに割当済みでないか | 原則スキップ |
| Entra IDユーザー | UPNのユーザーが存在するか | スキップ |
| DAG権限 | ユーザーが利用権限を持つか | 要確認またはスキップ |

既存AssignedUserが空でない場合、作業者判断で上書きしません。上書きが必要な場合は、依頼元または運用責任者の承認を前提にします。

## 7. DAG権限確認

Personal Desktopでは、AssignedUserを設定しても、Desktop Application Group側の権限がなければユーザーは利用できません。

確認観点は以下です。

| 確認項目 | 内容 |
|---|---|
| 直接割当 | ユーザーにDesktop Virtualization Userが直接付与されているか |
| グループ割当 | ユーザーが割当済みグループに所属しているか |
| ネストグループ | 必要に応じてネストグループを確認する |
| 対象DAG | 割当先HostPoolに対応するDAGか |

DAG権限が不足している場合、AssignedUser設定だけでは解決しません。作業結果としては前提不足として扱います。

## 8. DryRunと実行結果

DryRunでは、実際の割当を行わず、以下を出力します。

| 項目 | 内容 |
|---|---|
| SessionHost | 対象SessionHost |
| TargetUser | 割当予定ユーザー |
| CurrentAssignedUser | 現在のAssignedUser |
| UserExists | Entra ID上の存在確認 |
| DagAccess | DAG利用権限の確認結果 |
| CanAssign | 割当可能か |
| SkipReason | スキップ理由 |

実行後は、成功、失敗、スキップ理由、実行前後のAssignedUserをCSVまたはログとして出力します。

## 9. スキップ理由

| SkipReason | 内容 |
|---|---|
| HostPoolNotFound | HostPoolが存在しない |
| SessionHostNotFound | SessionHostが存在しない |
| AlreadyAssignedToAnotherUser | 別ユーザーが割当済み |
| UserAlreadyAssignedToAnotherHost | 同一ユーザーが別Hostへ割当済み |
| UserNotFound | Entra ID上にユーザーが存在しない |
| DagAccessNotConfirmed | DAG利用権限を確認できない |
| DryRunOnly | DryRunのため実行していない |

スキップは失敗ではありません。作業条件を満たさない対象を安全に処理しなかった結果として扱います。

## 10. 作業後確認

| 確認項目 | 内容 |
|---|---|
| AssignedUser | 対象SessionHostへ想定ユーザーが設定されているか |
| 重複割当 | 同一ユーザーが複数SessionHostへ割当されていないか |
| DAG権限 | 利用権限が不足していないか |
| 結果CSV | 成功、失敗、スキップが記録されているか |
| 顧客回答 | 必要に応じて確認結果を説明できるか |

## 11. 関連スクリプト

| Script | 役割 |
|---|---|
| `Set-AvdPersonalDesktopAssignment.ps1` | AssignedUser割当の事前確認、DryRun、実行、結果出力を行う |
| `Export-AvdHostPoolInventory.ps1` | 割当前後の棚卸しに使う |

## 12. まとめ

Personal DesktopのAssignedUser割当では、割当操作そのものよりも、事前確認と作業後確認が重要です。

既存割当、重複割当、Entra IDユーザー、DAG権限を確認し、DryRunと結果出力を用意することで、誤割当や利用不可状態を減らします。
