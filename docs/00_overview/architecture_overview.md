# Architecture Overview

## 1. 目的

この文書では、本構成の全体像を整理する。

対象は、中堅規模の組織がAzure利用を広げる前に整えておきたい、最低限のGovernance Baselineである。
大規模なEnterprise Scale Landing Zoneをそのまま作るのではなく、まずはSubscription単位で導入しやすい構成に絞る。

本構成で重視するのは、リソースを作ること自体ではない。
Azure利用が広がった後でも、権限、タグ、ログ、コスト、Policy、例外運用、Evidenceを追える状態にすることを目的とする。

## 2. 全体像

本構成は、以下の要素で構成する。

~~~text
Azure Governance Baseline
├─ Scope Design
│  ├─ Subscription
│  └─ Resource Group
│
├─ Governance Controls
│  ├─ Azure Policy
│  ├─ RBAC
│  ├─ Tagging Standard
│  └─ Exception Operation
│
├─ Operations Baseline
│  ├─ Log Analytics Workspace
│  ├─ Diagnostic Settings
│  ├─ Cost Management Notes
│  └─ Evidence
│
├─ Implementation
│  ├─ Bicep
│  └─ Azure CLI Runbook
│
└─ Applied Operations Example
   └─ AVD Operations Standardization
~~~

## 3. 論理構成

初期版では、Subscription配下に共通基盤用と検証用のResource Groupを分けて配置する。

~~~text
Subscription
├─ rg-platform-monitoring
│  └─ Log Analytics Workspace
│
├─ rg-platform-network
│  └─ Minimal network resources
│
└─ rg-workload-sample
   └─ Sample workload resources
~~~

この構成では、まず共通的な監視・ログ出力先を用意し、その上でPolicy、RBAC、Tag標準を適用する。

## 4. スコープの考え方

初期版では、Management Groupを必須にしない。

理由は、個人検証環境や小規模な導入検討では、Management Groupを前提にすると準備が重くなるためである。
まずはSubscription単位で再現できる構成にし、後からManagement Groupへ展開できるようにする。

| スコープ | 初期版での扱い |
|---|---|
| Management Group | 将来拡張。初期版では必須にしない |
| Subscription | Governance Baselineの基本適用単位 |
| Resource Group | 用途別、ライフサイクル別の管理単位 |
| Resource | Diagnostic SettingsやTag確認の対象 |

## 5. 主要コンポーネント

### 5.1 Azure Policy

Azure Policyは、ルール違反を検出し、必要に応じて制御するために利用する。

初期版ではAuditを中心にする。
最初からDenyで止めると、既存運用や検証作業と衝突しやすいため、まずは現状を見える化する。

主な対象は以下。

- 必須タグ
- 利用可能リージョン
- Public IP利用
- Diagnostic Settings
- Storage Account公開設定
- Key Vault保護設定

### 5.2 RBAC

RBACは、最小権限とスコープ分離を基本にする。

Subscription全体に広くOwnerやContributorを付与しない。
通常運用はResource Group単位で分け、必要に応じてReader、Contributor、Ownerの範囲を整理する。

主な考え方は以下。

- 個人ではなくグループ付与を基本にする
- Subscription全体の強権限を絞る
- 通常運用はResource Group単位にする
- 一時権限は期限と理由を残す
- 棚卸しを前提にする

### 5.3 Tagging Standard

タグは、所有者、環境、コスト、用途を追うために使う。

初期版の必須タグは以下。

| Tag Key | 用途 |
|---|---|
| Environment | dev / test / prod / shared / sandbox |
| Owner | 所有部門または担当チーム |
| CostCenter | コスト集計単位 |
| Workload | ワークロード名 |
| ManagedBy | iac / manual などの管理方法 |

タグは後から整理するのではなく、リソース作成時点で付与する。

### 5.4 Log Analytics / Diagnostic Settings

ログは、障害対応や監査対応の前提になる。

初期版では、Log Analytics Workspaceを共通ログ出力先として用意する。
対象リソースについては、Diagnostic Settingsの設定有無を確認し、必要なログをWorkspaceへ送る。

ただし、すべてのログを無条件に集めるとコストが増える。
まずは必要な範囲に絞り、運用に合わせて追加する。

### 5.5 Cost Management

初期版では、詳細なFinOps設計までは扱わない。

まずは、Resource GroupとTagを組み合わせて、どのリソースが何の目的で作られたかを追える状態にする。
検証環境では、不要リソースを削除できることもコスト管理の一部として扱う。

### 5.6 Exception Operation

標準を決めても、実運用では例外が発生する。

例外を禁止するのではなく、理由、期限、承認者、見直し予定を残す。
期限や解除条件がない例外は、実質的に標準の崩れになるため避ける。

## 6. 実装構成

IaCはBicepを中心にする。
操作はAzure CLIを基本とする。

~~~text
infra/
├─ main.bicep
├─ parameters/
│  ├─ dev.bicepparam
│  └─ lowcost-demo.bicepparam
└─ modules/
   ├─ resource-groups/
   ├─ monitoring/
   ├─ policy/
   ├─ rbac/
   ├─ tagging/
   └─ network/
~~~

初期実装では、すべてのモジュールを作り込みすぎない。
まずは、Resource Group、Log Analytics Workspace、Policy Assignment、RBAC Assignment、Tagを中心にする。

## 7. Runbook構成

Azure CLIのRunbookは、以下の流れで整理する。

~~~text
scripts/cli/
├─ login.sh
├─ set-subscription.sh
├─ whatif.sh
├─ deploy.sh
├─ validate.sh
└─ teardown.sh
~~~

Runbookでは、デプロイだけでなく、事前確認、検証、削除まで扱う。

特に、検証用構成ではTeardownが重要になる。
作ったリソースを削除できない構成は、低コスト検証に向かない。

## 8. Evidence構成

Evidenceは、設計、実装、確認結果をつなぐために残す。

~~~text
docs/04_evidence/
├─ 01-what-if-result.md
├─ 02-deployment-result.md
├─ 03-policy-assignment-result.md
├─ 04-rbac-validation-result.md
├─ 05-diagnostic-settings-result.md
└─ 06-validation-summary.md
~~~

Evidenceでは、実環境のTenant ID、Subscription ID、ユーザー名、顧客名、内部リソース名をそのまま残さない。
必要に応じて、サンプル値やマスク値に置き換える。

## 9. AVD運用標準化の位置づけ

AVD運用標準化は、本構成のサブテーマとして扱う。

主役はAzure Governance / Policy Baselineである。
AVD側は、実運用で発生しやすい作業を、確認、実行、記録まで含めて標準化する適用例として置く。

対象例。

- HostPool棚卸し
- SessionHost削除
- Personal Desktopのユーザー割当
- 接続不可時の切り分け
- 作業前後チェック
- 顧客回答テンプレート

これは、Governanceの考え方を実際の運用作業に落とし込む例として扱う。

## 10. 初期版の優先順位

初期版では、以下の順に整備する。

1. Overview / Scope / Requirements
2. Governance Design
3. Policy Baseline
4. RBAC / Tag / Monitoring / Cost / Exception / Validation
5. Bicep Skeleton
6. Azure CLI Runbook
7. Evidence Template
8. ADR
9. AVD Operations Standardization

AVD運用標準化は重要だが、先にGovernance Baselineを固める。
そうすることで、AVDスクリプト群が単なる便利ツールではなく、CloudOps標準化の実例として見える。

## 11. まとめ

本構成は、Azure利用拡大前に必要となる最低限の統制を、設計、IaC、Runbook、Evidenceとして整理するものである。

重要なのは、個別リソースを作れることではなく、Azure環境を継続的に管理できる状態にすること。
そのために、Policy、RBAC、Tag、Log、Cost、Exception、Evidenceを分けて考え、後から追える形にする。
