# Governance Design

## 1. 目的

この文書では、Azure Governance Baselineの全体設計を整理します。

ここでいうガバナンスは、Policyを割り当てるだけの話ではありません。リソース配置、権限、Tag、Log、Cost、例外、Evidenceをあらかじめ整理し、Azure利用が広がっても管理しやすい状態を作ることを指します。

## 2. 設計範囲

初期PoCでは、Subscriptionスコープを中心に以下を扱います。

| 領域 | 内容 |
|---|---|
| スコープ設計 | Subscription / Resource Group / Resourceの役割を整理 |
| Azure Policy | 標準からの逸脱を検出・制御 |
| RBAC | 最小権限とスコープ分離 |
| Tag | 所有者、環境、用途、コスト集計単位を明確化 |
| Monitoring / Logging | Log Analytics WorkspaceとDiagnostic Settingsの標準化 |
| Cost | TagとResource Groupを使った初期コスト管理 |
| Exception | 例外理由、期限、承認者、見直し予定を記録 |
| Evidence | What-If、Deploy、Validate結果を記録 |

Management Groupは初期PoCの必須要素にはしません。複数Subscriptionへ展開する段階で、Policy Assignmentや階層設計の適用先として扱います。

## 3. 非対象範囲

初期PoCでは、以下は対象外です。

| 対象外 | 理由 |
|---|---|
| 複数Management Groupを用いた全社階層 | 初期PoCとして範囲が広すぎるため |
| 本格的なHub-Spokeネットワーク | 通信要件とセキュリティ要件が別途必要なため |
| ExpressRoute / VPN設計 | 個別環境依存が大きいため |
| Sentinel / SOC設計 | 監視運用設計まで範囲が広がるため |
| IDライフサイクル詳細設計 | 人事・組織運用との連携が必要なため |
| アプリケーション設計 | Azure基盤統制とは別領域のため |
| 実際の承認ワークフロー | 組織固有の運用に依存するため |

## 4. 全体方針

| 項目 | 方針 |
|---|---|
| 導入単位 | 初期PoCはSubscription単位 |
| IaC | Bicepで再現可能にする |
| 操作手段 | Azure CLIを基本にする |
| Policy | Audit中心から始め、必要に応じてDenyへ移行 |
| RBAC | 最小権限、グループ付与、スコープ分離 |
| Tag | 作成時点で必須Tagを付与 |
| Log | Log Analytics Workspaceを共通出力先として扱う |
| Cost | Resource GroupとTagで追跡しやすくする |
| Exception | 理由、期限、承認、見直しを記録 |
| Evidence | 実行結果と確認結果を残す |

## 5. スコープ設計

### 5.1 Management Group

Management Groupは、初期PoCでは必須にしません。

ただし、現在は作成可能な前提に変わっているため、将来拡張の選択肢として明記します。複数Subscriptionへ同じ統制を展開する場合は、Management GroupスコープでのPolicy Assignmentや階層設計を検討します。

初期PoCで扱わない理由は、検証範囲が広がり、Bicep、Runbook、Evidenceの修正範囲も大きくなるためです。

### 5.2 Subscription

Subscriptionは、初期PoCの基本適用単位です。

Policy、RBAC、Cost、Activity Log確認など、Subscription単位で意味を持つ統制をここに集約します。

### 5.3 Resource Group

Resource Groupは、用途とライフサイクルが近いリソースをまとめる単位です。

初期PoCでは、以下の構成を想定します。

| Resource Group | 用途 |
|---|---|
| `rg-apg-<env>-monitoring` | Log Analytics Workspaceなどの監視基盤 |
| `rg-apg-<env>-network` | 最小ネットワーク構成 |
| `rg-apg-<env>-workload-sample` | 検証用ワークロード |

## 6. 主要設計

### 6.1 Policy

Azure Policyは、標準からの逸脱を検出・制御するために使います。

初期PoCではAudit中心で開始します。既存運用や検証作業への影響を確認したうえで、必要なものだけDenyへ移行します。

主な対象は以下です。

- 必須Tag
- 利用可能リージョン
- Public IP利用
- Diagnostic Settings
- Storage Account公開設定
- Key Vault保護設定

### 6.2 RBAC

RBACは、最小権限とスコープ分離を基本にします。

Subscription全体へのOwnerやContributor付与は最小限にし、通常運用はResource Group単位、または用途別グループ単位で付与します。

| 役割 | 想定スコープ | 主な用途 |
|---|---|---|
| Platform Owner | Subscription | ガバナンス設計、基盤管理 |
| Platform Operator | Resource Group | 共通基盤の運用 |
| Workload Owner | Workload Resource Group | 個別ワークロード管理 |
| Reader / Auditor | Subscription or Resource Group | 監査、確認、レビュー |

### 6.3 Tag

Tagは、所有者確認、環境区分、コスト集計、運用問い合わせの起点として扱います。

初期PoCの標準Tagは以下です。

| Tag Key | 用途 | 例 |
|---|---|---|
| Environment | 環境区分 | dev / test / prod |
| Owner | 所有部門または担当 | platform-team |
| CostCenter | コスト集計単位 | cc-0001 |
| Workload | ワークロード名 | sample-app |
| ManagedBy | 管理方法 | iac / manual |

### 6.4 Monitoring / Logging

Log Analytics Workspaceを共通のログ出力先として扱います。

Diagnostic Settingsは、必要なリソースから段階的に設定・確認します。すべてのログを無条件に収集するとコストが増えるため、対象リソースとログカテゴリは検証しながら調整します。

### 6.5 Cost

初期PoCでは、本格的なFinOps設計までは扱いません。

まずは、Resource GroupとTagにより、どのリソースが何の目的で作られたかを追える状態にします。また、検証後にTeardownできることもコスト管理の一部として扱います。

### 6.6 Exception

標準を決めても、実運用では例外が発生します。

例外を認める場合は、以下を記録します。

- 例外対象
- 例外理由
- 影響範囲
- 承認者
- 期限
- 見直し予定

期限や見直し予定がない例外は、標準の形骸化につながるため避けます。

### 6.7 Evidence

Evidenceは、設計と実装結果の整合性を確認するために残します。

初期PoCでは、以下を記録対象にします。

| Evidence | 内容 |
|---|---|
| What-If結果 | デプロイ前の差分確認 |
| Deployment結果 | デプロイ成否と主要出力 |
| Policy Assignment結果 | 割り当て済みPolicyの確認 |
| RBAC確認結果 | ロール割り当ての確認 |
| Diagnostic Settings結果 | ログ出力設定の確認 |
| Validation Summary | 全体確認結果 |

## 7. 実装優先順位

初期PoCでは、以下の順に実装します。

1. Resource Group構成
2. Log Analytics Workspace
3. Tag標準
4. Policy Assignment
5. RBAC設計 / PoC実行権限確認
6. Monitoring Baseline確認
7. What-If / Deploy / Validate / Teardown Runbook
8. Evidence反映

## 8. まとめ

この設計では、Azure利用を広げる前に必要となる最低限の統制を整理します。

重視するのは、個別リソースを作ることではなく、Policy、RBAC、Tag、Log、Cost、例外、Evidenceを運用可能な形でつなげることです。
