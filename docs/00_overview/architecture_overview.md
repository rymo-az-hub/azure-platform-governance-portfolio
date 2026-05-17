# Architecture Overview

## 1. 目的

この文書では、リポジトリ全体の構成を整理します。

対象は、中堅規模の組織がAzure利用を広げる前に整えておきたい、軽量なAzure Governance Baselineです。初期版では、Management Groupを前提にした全社規模のLanding Zoneではなく、Subscription単位で検証しやすい範囲に絞ります。

## 2. 全体構成

本リポジトリは、以下の構成です。

~~~text
Azure Platform Governance Portfolio
├─ Azure Governance / Policy Baseline
│  ├─ Scope Design
│  ├─ Azure Policy
│  ├─ RBAC
│  ├─ Tagging Standard
│  ├─ Monitoring / Logging
│  ├─ Cost Management
│  ├─ Exception Operation
│  └─ Evidence
│
├─ Implementation
│  ├─ Bicep
│  └─ Azure CLI Runbook
│
├─ Architecture Decision Records
│  └─ ADR
│
└─ AVD Operations Standardization
   ├─ Inventory / Pre-check
   ├─ SessionHost Lifecycle
   ├─ Personal Desktop Assignment
   ├─ Troubleshooting Flow
   └─ Operation Scripts
~~~

## 3. 論理構成

初期版では、Subscription配下に用途別のResource Groupを配置します。

~~~text
Subscription
├─ rg-apg-<env>-monitoring
│  └─ Log Analytics Workspace
│
├─ rg-apg-<env>-network
│  └─ Minimal network resources
│
└─ rg-apg-<env>-workload-sample
   └─ Sample workload resources
~~~

この構成で、監視・ログ出力先、Policy、RBAC、Tag標準を確認できる状態にします。

## 4. スコープ設計

初期版の基本スコープはSubscriptionです。

| スコープ | 初期版での扱い |
|---|---|
| Management Group | 将来拡張。初期版では必須にしない |
| Subscription | Governance Baselineの基本適用単位 |
| Resource Group | 用途別、ライフサイクル別の管理単位 |
| Resource | Tag、Diagnostic Settings、削除確認の対象 |

Management Groupを最初から必須にしない理由は、個人検証環境や小規模な導入検討では準備が重くなるためです。まずはSubscription単位で再現できる構成にします。

## 5. 主要コンポーネント

| 領域 | 役割 |
|---|---|
| Azure Policy | 必須Tag、利用リージョン、Public IPなどの逸脱を検出する |
| RBAC | 作業者、スコープ、権限範囲を整理する |
| Tagging Standard | 所有者、環境、コスト、用途を追えるようにする |
| Log Analytics | ログ出力先を標準化する |
| Diagnostic Settings | 必要なリソースログを取得できる状態にする |
| Cost Management | TagとResource Groupを使い、コストの所在を追いやすくする |
| Exception Operation | 標準から外れる場合の理由、期限、承認を記録する |
| Evidence | 設計、実装、検証結果を後から確認できるようにする |

## 6. 実装構成

IaCはBicepを中心にします。操作はAzure CLIを基本にし、ローカル実行環境はPowerShell 7を想定します。

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

初期実装では、Resource Group、Log Analytics Workspace、Policy Assignment、RBAC Assignment、Tag、最小ネットワーク構成を中心にします。

## 7. RunbookとEvidence

Runbookは、作成だけでなく、事前確認、What-If、Deploy、Validate、Teardownまで扱います。

Evidenceは、次の結果を記録するために用意します。

- What-If結果
- Deployment結果
- Policy Assignment確認
- RBAC確認
- Diagnostic Settings確認
- Validation Summary

実Tenant ID、Subscription ID、UPN、顧客固有値は記録しません。必要な場合はサンプル値またはマスク値に置き換えます。

## 8. AVD運用標準化の位置づけ

AVD運用標準化はサブテーマです。

主役はAzure Governance / Policy Baselineであり、AVD側は運用標準化の適用例として配置しています。

具体的には、以下を扱います。

- HostPool棚卸し
- SessionHost削除・整理
- Personal Desktop割当
- 接続不可時の切り分け
- 作業チェックリスト
- 顧客回答テンプレート
- 公開用に抽象化した運用スクリプト

## 9. 初期版の優先順位

初期版では、以下の順で整備します。

1. Scope / Overview
2. Governance Design
3. Policy / RBAC / Tag / Log / Cost / Exception
4. Bicep Skeleton
5. Azure CLI Runbook
6. Evidence Template
7. ADR
8. AVD Operations Standardization
9. PoC実行結果の反映

## 10. まとめ

本構成は、Azure環境を継続的に管理するための最小構成を示すものです。

個別リソースを作れることではなく、統制、運用、検証、証跡をセットで扱える状態を重視します。
