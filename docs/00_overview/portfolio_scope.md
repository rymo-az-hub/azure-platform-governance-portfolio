# Portfolio Scope

## 1. 目的

この文書では、このリポジトリで扱う範囲と扱わない範囲を整理します。

本リポジトリは、中堅規模の組織を想定した Azure Governance / Policy Baseline の設計・実装例です。AVD運用標準化は、Azure基盤運用を実務に落とし込むサブテーマとして扱います。

## 2. 想定読者

主な想定読者は以下です。

- Azure基盤エンジニア
- Cloud Platform Engineer
- CloudOps改善担当
- Microsoft系クラウド基盤の設計・運用担当
- 技術寄りITコンサルタント
- 設計意図、運用観点、証跡化の考え方を確認したいレビュー担当者

## 3. 想定シナリオ

Azure利用が広がる前に、最低限の統制を整えたい中堅規模の組織を想定します。

前提となる課題は以下です。

- リソースの所有者が分かりにくい
- RBACの付与範囲が曖昧になりやすい
- Tag標準がなく、コストや用途を追いにくい
- Diagnostic Settingsやログ出力先が統一されていない
- 例外運用が属人化しやすい
- デプロイや変更結果を後から確認しにくい

## 4. 主対象

主対象は、Subscription単位で導入できる軽量な Azure Governance / Policy Baseline です。

含める範囲は以下です。

| 領域 | 内容 |
|---|---|
| スコープ設計 | Subscription / Resource Groupを基本単位として整理 |
| Azure Policy | 必須Tag、利用リージョン、Public IPなどの初期統制 |
| RBAC | 最小権限、グループ付与、スコープ分離 |
| Tag標準 | Environment、Owner、CostCenter、Workload、ManagedBy |
| 監視・ログ | Log Analytics Workspace、Diagnostic Settingsの考え方 |
| コスト管理 | TagとResource Groupを使った初期管理 |
| 例外運用 | 例外理由、期限、承認、見直しの記録 |
| Evidence | What-If、Deploy、Policy、RBAC、ログ設定の確認結果 |

## 5. サブ対象

サブ対象は、AVD運用標準化です。

AVDを主題にするのではなく、Azure基盤運用の標準化を実務に適用した例として扱います。

含める範囲は以下です。

- HostPool棚卸し
- SessionHostライフサイクル
- Personal Desktop割当
- 接続不可時の切り分け
- 作業チェックリスト
- 顧客回答テンプレート
- 公開用に抽象化した運用スクリプト

## 6. 対象外

初期版では、以下は対象外です。

| 対象外 | 理由 |
|---|---|
| Enterprise Scale Landing Zone全体 | 初期版として範囲が広すぎるため |
| 本番Hub-Spokeネットワーク | 詳細な通信要件が必要になるため |
| ExpressRoute / VPN設計 | 個別要件依存が大きいため |
| Microsoft Sentinel本格設計 | 監視・SOC設計まで範囲が広がるため |
| IDライフサイクル詳細設計 | 人事・組織運用と密接に関わるため |
| アプリケーションアーキテクチャ | Azure基盤統制とは別領域として扱うため |
| 本格CI/CDリリース管理 | 初期版ではローカル検証を優先するため |
| 実案件固有の運用手順 | 公開リポジトリには含めないため |

## 7. 設計前提

設計前提は以下です。

- Azure CLIを基本操作手段とする
- IaCはBicepを中心にする
- 初期検証は低コストで実施できる範囲に絞る
- 検証後に不要リソースを削除できる構成にする
- PolicyはAudit中心から開始する
- Evidenceは設計・実装・運用確認をつなぐ記録として扱う
- 実環境固有の値は公開しない

## 8. 公開 / 非公開の境界

公開リポジトリには、以下を含めません。

- 顧客名
- 現職名、所属組織名
- 実案件名
- 実Tenant ID
- 実Subscription ID
- 実UPN
- 実IPアドレス一覧
- 実環境のHostPool名、VM名、Resource Group名
- 社内手順そのもの
- 面接用の補足メモ

必要な場合は、サンプル値またはマスク値に置き換えます。

## 9. 成果物

このリポジトリで扱う主な成果物は以下です。

- Overview資料
- Azure Governance / Policy Baseline設計書
- AVD運用標準化資料
- Bicepテンプレート
- Azure CLI Runbook
- PowerShell運用スクリプト
- ADR
- Evidenceテンプレート
- ローカル品質確認スクリプト

## 10. レビュー観点

このリポジトリは、以下の観点でレビューされることを想定しています。

- 設計意図が分かるか
- ガバナンス統制が現実的か
- 運用に渡せる形になっているか
- 例外と責任分界を考慮しているか
- IaC、Runbook、Evidenceがつながっているか
- 実務経験を標準化・自動化・証跡化へ落とし込めているか
