# Governance Design

## 1. 目的

この文書では、中堅規模の組織がAzureを利用する際に、最初に整えておきたいガバナンス設計を整理する。

ここでいうガバナンスは、単にPolicyを割り当てることではない。リソースの配置先、権限、タグ、ログ、コスト、例外運用、検証方法をあらかじめ決め、Azure利用が広がっても管理が破綻しにくい状態を作ることを指す。

本構成では、フルスケールのLanding Zoneではなく、Subscription単位で導入しやすいLightweightなGovernance Baselineを扱う。

## 2. 想定シナリオ

対象は、Azure利用をこれから広げていく中堅規模の組織とする。

既に一部のリソースは利用しているが、以下のような課題が出始めている状態を想定する。

- リソースの所有者が分かりにくい
- タグの付与ルールが統一されていない
- 権限付与の範囲が広くなりやすい
- ログ出力先がリソースごとにばらついている
- コストの集計単位が明確でない
- Policy違反や例外の扱いが明文化されていない
- 作業後の確認結果が残りにくい

この段階で最低限の標準を決めておくことで、後続のシステム追加や運用移管時の手戻りを減らす。

## 3. 設計範囲

本設計の対象範囲は以下とする。

- Subscription配下の基本統制
- Resource Group構成
- Azure Policyによる検出と制御
- RBACによる権限管理
- Tag標準
- Diagnostic SettingsとLog Analytics
- Cost管理に必要な情報整理
- 例外運用
- Evidenceの取得方針

初期版では、Management Groupを前提にした大規模な階層設計は扱わない。ただし、将来的にManagement Groupへ展開できるよう、PolicyやRBACの考え方はスコープを意識して設計する。

## 4. 非対象範囲

以下は初期版では対象外とする。

- 複数Management Groupを用いた全社階層設計
- Hub-Spokeネットワークの詳細設計
- ExpressRoute / VPNの接続設計
- Microsoft Sentinelの詳細設計
- IDライフサイクル管理の詳細設計
- アプリケーション基盤の設計
- 本番運用を前提とした完全な監視・通知設計
- 組織固有の承認フローや変更管理システム連携

これらは重要な設計領域ではあるが、初期段階で範囲を広げすぎると、Governance Baselineとしての主題がぼやけるため、別フェーズの拡張対象とする。

## 5. 全体方針

本設計では、以下の方針を採用する。

| 項目 | 方針 |
|---|---|
| 導入単位 | Subscription単位を基本とする |
| IaC | Bicepで再現可能にする |
| 操作手段 | Azure CLIを基本とする |
| Policy | 初期はAudit中心で影響を確認する |
| RBAC | 最小権限、用途別グループ、スコープ分離を基本とする |
| Tag | 所有者、環境、用途、コスト集計に必要な項目を標準化する |
| Log | Diagnostic Settingsの出力先を標準化する |
| Cost | タグとResource Group設計で集計しやすくする |
| Exception | 例外理由、期限、承認者を残す |
| Evidence | What-If、Deploy、Policy、RBAC、Log設定の結果を記録する |

## 6. スコープ設計

### 6.1 Management Group

初期版ではManagement Groupを必須とはしない。

個人検証や小規模な導入では、Management Groupを前提にすると準備が重くなるため、まずはSubscriptionスコープで再現できる構成とする。

ただし、将来的に複数Subscriptionへ展開する場合は、Management Group配下へPolicyやRBACを移すことを想定する。そのため、Policy定義や割り当ては、できるだけスコープ依存を強くしすぎない形で整理する。

### 6.2 Subscription

Subscriptionは、ガバナンス適用の基本単位とする。

初期版では、1つのSubscription内に検証用Resource Groupを作成し、Policy、RBAC、Tag、Logの動作を確認する。

Subscription全体に適用するものと、Resource Group単位で適用するものは分けて考える。

例として、以下のように整理する。

| 適用範囲 | 対象例 |
|---|---|
| Subscription | Policy assignment、基本RBAC、コスト集計、Activity Log確認 |
| Resource Group | Workload別リソース、運用担当権限、Diagnostic Settings確認 |
| Resource | 個別リソースの診断設定、タグ、ロック |

### 6.3 Resource Group

Resource Groupは、用途とライフサイクルが近いリソースをまとめる単位とする。

初期版では、以下のような構成を想定する。

| Resource Group | 用途 |
|---|---|
| rg-platform-monitoring | Log Analyticsなど共通監視基盤 |
| rg-platform-network | 最小ネットワーク構成 |
| rg-platform-security | Key Vaultなどセキュリティ関連リソースを配置する場合の候補 |
| rg-workload-sample | 検証用ワークロード |

初期実装では、すべてを作り込まず、監視基盤と検証用リソースを中心に扱う。

## 7. Policy設計

Azure Policyは、環境全体のルール逸脱を検出・制御するために利用する。

初期版では、いきなりDenyで止めるのではなく、Auditを中心に適用する。既存運用や検証作業への影響を確認したうえで、Denyへ移行する対象を決める。

想定するPolicy領域は以下とする。

| 領域 | 初期方針 |
|---|---|
| 必須タグ | Auditから開始 |
| 利用可能リージョン | AuditまたはDenyを検討 |
| Public IP | 原則Audit。必要に応じてDeny |
| Diagnostic Settings | AuditIfNotExistsを検討 |
| Storage Accountの公開設定 | Deny候補 |
| Key Vaultの保護設定 | AuditまたはDeny候補 |

Policyは、ルールを強制するだけではなく、現状の逸脱を見える化する目的でも利用する。

## 8. RBAC設計

RBACは、最小権限とスコープ分離を基本とする。

Subscription全体に広くOwnerやContributorを付与する運用は避ける。作業内容に応じて、Resource Group単位、または用途別グループ単位で権限を付与する。

想定するロール設計は以下とする。

| 役割 | 想定スコープ | 主な用途 |
|---|---|---|
| Platform Owner | Subscription | ガバナンス設計、基盤管理 |
| Platform Operator | Resource Group | 共通基盤の運用 |
| Workload Owner | Workload Resource Group | 個別システムの管理 |
| Reader / Auditor | Subscription or Resource Group | 監査、確認、レビュー |

初期版では、実ユーザーや実グループを使わず、サンプル名で設計を示す。

## 9. Tag設計

タグは、所有者確認、環境区分、コスト集計、運用問い合わせの起点として扱う。

初期版では、以下のタグを標準とする。

| Tag Key | 用途 | 例 |
|---|---|---|
| Environment | 環境区分 | dev / test / prod |
| Owner | 所有部門または担当 | platform-team |
| CostCenter | コスト集計単位 | cc-0001 |
| Workload | ワークロード名 | sample-app |
| ManagedBy | 管理主体 | iac / manual |

タグは、後から整理するのではなく、リソース作成時点で付与する前提とする。

## 10. Log / Monitoring設計

ログは、障害対応や監査対応の前提になる。

初期版では、Log Analytics Workspaceを共通のログ出力先として扱う。対象リソースにはDiagnostic Settingsを設定し、必要なログとメトリックを収集できる状態にする。

最初からすべてのログカテゴリを収集するとコストが増えるため、収集対象は検証しながら調整する。

設計上は、次の点を確認する。

- どのリソースからログを取得するか
- どのLog Analytics Workspaceへ送るか
- 保持期間はどうするか
- コスト増加の可能性はあるか
- 設定結果をどう確認するか

## 11. Cost管理

Cost管理では、タグとResource Group設計を組み合わせて、利用状況を確認しやすくする。

初期版では、複雑なFinOps設計までは行わない。まずは、コスト集計に必要なタグとResource Groupの単位を揃える。

確認観点は以下とする。

- CostCenterタグが付与されているか
- Environmentごとに集計できるか
- Workload単位で追えるか
- 不要リソースを削除できるか
- 検証後のTeardown手順があるか

## 12. 例外運用

PolicyやTag標準を定義しても、実運用では例外が発生する。

例外を認める場合は、少なくとも以下を残す。

- 例外対象
- 例外理由
- 影響範囲
- 承認者
- 期限
- 見直し予定

例外を記録しない場合、標準が形骸化しやすい。例外は標準からの逸脱として扱い、恒久化しないようにする。

## 13. Evidence設計

Evidenceは、作業結果と設計の整合性を確認するために残す。

初期版では、以下をEvidenceとして記録する。

| Evidence | 内容 |
|---|---|
| What-If結果 | デプロイ前の差分確認 |
| Deployment結果 | デプロイ成否と主要出力 |
| Policy Assignment結果 | 割り当て済みPolicyの確認 |
| RBAC確認結果 | ロール割り当ての確認 |
| Diagnostic Settings結果 | ログ出力設定の確認 |
| Validation Summary | 全体の確認結果 |

Evidenceには、実環境の機密情報を含めない。必要に応じてマスクした値やサンプル値に置き換える。

## 14. 初期実装の優先順位

初期実装では、以下の順に作成する。

1. Resource Group構成
2. Log Analytics Workspace
3. Tag標準
4. Policy Assignment
5. RBAC Assignment
6. Diagnostic Settings
7. What-If / Deploy / Validate用Runbook
8. Evidenceテンプレート

AVD運用標準化は、Governance Baselineの後に、実運用への適用例として整備する。

## 15. まとめ

本設計では、Azure利用を広げる前に必要となる最低限のガバナンスを整理する。

重要なのは、個別リソースを作れることではなく、Azure環境を継続的に管理できる状態にすることである。

そのために、Policy、RBAC、Tag、Log、Cost、例外運用、Evidenceを分けて考え、BicepとRunbookで再現できる形にする。
