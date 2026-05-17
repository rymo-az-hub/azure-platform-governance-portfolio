# Monitoring and Logging Design

## 1. 目的

この文書では、Azure Governance Baselineにおける監視とログ収集の初期設計を整理します。

監視とログは、障害対応、監査、運用改善の前提です。障害発生後にログ未設定へ気付いても、過去の情報は取得できません。そのため、現行PoCではLog Analytics Workspaceを共通ログ出力先として用意し、Diagnostic Settings詳細適用は将来拡張として設計上の候補に含めます。

## 2. 基本方針

| 項目 | 方針 |
|---|---|
| ログ出力先 | Log Analytics Workspaceを基本にする |
| 設定方法 | IaCまたはRunbookで再現できるようにする |
| 対象 | 初期PoCでは共通基盤リソースを中心にする |
| コスト | 必要なログから段階的に収集する |
| Evidence | 設定結果と確認結果を残す |
| 拡張 | 必要に応じてAlertやSentinelへ広げる |

初期PoCでは、すべてのログを広く集めるのではなく、確認価値のあるログから始めます。

## 3. Log Analytics Workspace

Log Analytics Workspaceは、共通のログ出力先として作成します。

主な用途は以下です。

- Diagnostic Settingsの出力先
- 障害調査時のログ確認
- 監査用の基本ログ保管
- 運用改善時の確認材料

想定配置先は以下です。

```text
rg-apg-<env>-monitoring
```

## 4. Diagnostic Settings

Diagnostic Settingsは、Azureリソースのログやメトリックを指定した出力先へ送る設定です。

現行PoCでは、Diagnostic Settingsの詳細適用は実装対象外です。まずLog Analytics Workspaceを共通ログ出力先として作成し、各リソースへのDiagnostic Settings適用、Activity Log export、Alert設計は将来拡張として扱います。

| 確認項目 | 内容 |
|---|---|
| 対象リソース | どのリソースからログを取得するか |
| ログカテゴリ | どのログを収集するか |
| メトリック | メトリックも送るか |
| 出力先 | Log Analytics Workspace |
| 保持期間 | Workspace側の設定に従う |
| コスト影響 | 収集量が増えすぎないか |

## 5. 初期対象

| 対象 | 目的 |
|---|---|
| Log Analytics Workspace | 共通ログ出力先の用意 |
| VNet | Governance Baselineの検証対象リソース |
| Diagnostic Settings | 将来拡張 |
| Activity Log export | 将来拡張 |
| Alert | 将来拡張 |

すべてを初期実装に含める必要はありません。PoCでは、検証しやすいものから扱います。

## 6. 収集対象の考え方

ログは多ければよいわけではありません。収集量が増えると、コストと確認負荷も増えます。

収集対象は以下の観点で決めます。

- 障害調査に使うか
- セキュリティ確認に使うか
- 監査時に必要か
- 運用者が確認できるか
- コストに見合うか

## 7. Activity Log

Activity Logは、Subscriptionレベルの操作確認に使います。

主な確認対象は以下です。

- リソース作成
- リソース削除
- 設定変更
- Policy割り当て
- RBAC変更
- デプロイ操作

必要に応じてLog Analytics Workspaceへエクスポートします。

## 8. Alert設計の扱い

初期PoCでは、詳細なAlert設計は対象外です。

Alertは、通知先、対応時間、一次対応者、エスカレーション先、閾値調整とセットで設計する必要があります。PoCではログを残せる状態を優先し、Alertは拡張候補として扱います。

## 9. 実装方針

監視関連リソースは、以下で管理します。

```text
infra/modules/monitoring/main.bicep
```

初期PoCで扱う主な項目は以下です。

- Log Analytics Workspace
- Workspaceの保持期間
- 共通Tag
- Diagnostic Settings詳細適用（将来拡張）

主なパラメータは以下です。

- `workspaceName`
- `location`
- `retentionInDays`
- `commonTags`
- `diagnosticSettingName`（将来拡張）

## 10. 確認方針

Log Analytics Workspaceの確認例です。

```bash
az monitor log-analytics workspace show \
  --resource-group <resource-group-name> \
  --workspace-name <workspace-name>
```

Diagnostic Settingsの確認例です。

```bash
az monitor diagnostic-settings list \
  --resource <resource-id>
```

確認結果は、`docs/04_evidence/05-diagnostic-settings-result.md` に記録します。現行PoCではMonitoring Baseline Resultとして、Log Analytics Workspace / VNetの作成確認を中心に扱います。

## 11. 運用時の確認観点

- Log Analytics Workspaceが作成されているか
- 対象リソースにDiagnostic Settingsが設定されているか
- 出力先Workspaceが正しいか
- 不要に多いログを収集していないか
- 保持期間が過剰でないか
- 障害時に運用者が確認できるか
- 設定結果がEvidenceとして残っているか

## 12. まとめ

現行PoCでは、Log Analytics Workspaceを共通ログ出力先として作成し、監視・ログ基盤の土台を確認します。

Diagnostic Settings詳細適用、Activity Log export、Alert、Sentinel連携は将来拡張とし、まずは障害対応や監査対応で確認できるログ基盤の入口を優先します。
