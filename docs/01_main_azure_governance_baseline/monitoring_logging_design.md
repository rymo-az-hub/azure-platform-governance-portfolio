# Monitoring and Logging Design

## 1. 目的

この文書では、Azure環境における監視とログ収集の初期設計を整理する。

監視とログは、障害対応、監査、運用改善の前提になる。障害が起きた後にログが出ていないことに気付いても、過去の情報は取得できない。

そのため、本構成ではDiagnostic SettingsとLog Analytics Workspaceを初期設計に含める。

## 2. 基本方針

監視・ログ設計では、以下を基本方針とする。

| 項目 | 方針 |
|---|---|
| ログ出力先 | Log Analytics Workspaceを基本とする |
| 設定方法 | IaCまたはRunbookで再現できるようにする |
| 対象 | 初期版では共通基盤リソースを中心にする |
| コスト | 収集対象を絞って開始する |
| Evidence | 設定結果を記録する |
| 拡張 | 必要に応じてAlertやSentinelへ広げる |

初期段階では、すべてのログを広く集めるのではなく、運用上必要なログから開始する。

## 3. Log Analytics Workspace

Log Analytics Workspaceは、共通のログ収集先として用意する。

初期版では、以下のような用途を想定する。

- Diagnostic Settingsの出力先
- Policy準拠状況の確認補助
- 障害調査時のログ確認
- 監査用の基本ログ保管
- 運用改善時の確認材料

Workspaceは、共通基盤用Resource Groupに配置する。

想定Resource Group:

~~~text
rg-platform-monitoring
~~~

## 4. Diagnostic Settings

Diagnostic Settingsは、Azureリソースのログやメトリックを指定した出力先へ送る設定である。

初期版では、対応リソースに対してDiagnostic Settingsの設定有無を確認し、必要なものからLog Analytics Workspaceへ送る。

確認する主な項目は以下。

| 項目 | 内容 |
|---|---|
| 対象リソース | どのリソースからログを取得するか |
| ログカテゴリ | どのログを収集するか |
| メトリック | メトリックも送るか |
| 出力先 | Log Analytics Workspace |
| 保持期間 | Workspace側の設定に従う |
| コスト影響 | 収集量が増えすぎないか |

## 5. 初期対象リソース

初期版では、以下を優先的に扱う。

| 対象 | 目的 |
|---|---|
| Log Analytics Workspace | 監視基盤自体の配置 |
| Key Vault | 監査ログ、アクセス確認 |
| Network Security Group | 通信確認、将来拡張 |
| Storage Account | アクセスログ、公開設定確認 |
| Azure Activity Log | Subscriptionレベルの操作確認 |

すべてを初期実装に含める必要はない。まずは、検証環境で扱いやすいものから作成する。

## 6. 収集対象の考え方

ログは多ければよいわけではない。収集量が増えれば、コストと確認負荷も増える。

初期段階では、以下の観点で収集対象を決める。

- 障害調査に使うか
- セキュリティ確認に使うか
- 監査時に必要か
- 運用者が確認できるか
- コストに見合うか

使わないログを大量に集めても、運用上の価値は低い。まずは必要なログを絞り、運用に合わせて増やす。

## 7. Activity Log

Activity Logは、Subscriptionレベルの操作確認に使う。

確認できる主な内容は以下。

- リソース作成
- リソース削除
- 設定変更
- Policy割り当て
- RBAC変更
- デプロイ操作

Activity Logは、変更作業の確認やトラブル調査で重要になる。必要に応じてLog Analytics Workspaceへエクスポートする。

## 8. Alert設計の扱い

初期版では、詳細なAlert設計は対象外とする。

理由は、通知先、対応時間、一次対応者、エスカレーション先、閾値調整など、運用体制とセットで設計する必要があるためである。

ただし、将来的な拡張として以下は検討する。

- 重要リソースの停止検知
- 高コスト検知
- Policy非準拠増加の確認
- Diagnostic Settings未設定検知
- Security関連の高重要度アラート

## 9. Bicep実装方針

監視関連リソースは、以下の構成で管理する。

~~~text
infra/modules/monitoring/
└─ main.bicep
~~~

初期実装で想定するもの。

- Log Analytics Workspace
- 必要に応じたDiagnostic Settings
- Workspaceの保持期間
- 共通タグ

パラメータ化する項目。

- workspaceName
- location
- retentionInDays
- commonTags
- diagnosticSettingName

## 10. Azure CLI確認方針

Log Analytics Workspaceの確認。

~~~bash
az monitor log-analytics workspace show \
  --resource-group <resource-group-name> \
  --workspace-name <workspace-name>
~~~

Diagnostic Settingsの確認。

~~~bash
az monitor diagnostic-settings list \
  --resource <resource-id>
~~~

Activity Logの確認。

~~~bash
az monitor activity-log list \
  --max-events 10
~~~

確認結果は、以下に記録する。

~~~text
docs/04_evidence/05-diagnostic-settings-result.md
~~~

## 11. 運用時の確認観点

監視・ログ運用では、以下を確認する。

- Log Analytics Workspaceが作成されているか
- 対象リソースにDiagnostic Settingsが設定されているか
- 出力先が正しいWorkspaceになっているか
- 不要に多いログを収集していないか
- 保持期間が過剰でないか
- 障害時に運用者がログを確認できるか
- 設定結果がEvidenceとして残っているか

## 12. まとめ

監視とログは、障害対応や監査対応のために後から必要になることが多い。

初期版では、Log Analytics WorkspaceとDiagnostic Settingsを中心に、最低限のログ出力先を標準化する。詳細なAlertやSentinel連携は将来拡張とし、まずはログを残せる状態を優先する。
