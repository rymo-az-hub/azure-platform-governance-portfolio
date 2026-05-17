# Requirements

## 1. 目的

この文書では、Azure Governance Baselineを設計するうえでの前提、要件、制約を整理する。

本構成は、Azure利用をこれから広げていく中堅規模の組織を想定している。すでに一部のAzureリソースは利用しているが、権限、タグ、ログ、コスト、例外運用が明確に標準化されていない状態を前提とする。

ここでは、大規模なEnterprise Scale Landing Zoneを最初から作り込むのではなく、Subscription単位で導入しやすいLightweightなGovernance Baselineを対象とする。

## 2. 想定顧客

想定する組織は以下とする。

| 項目 | 内容 |
|---|---|
| 組織規模 | 中堅規模 |
| Azure利用状況 | 一部利用済み、または利用拡大前 |
| 運用体制 | 少人数のインフラまたはクラウド運用チーム |
| 課題 | 権限、タグ、ログ、コスト、例外運用が標準化されていない |
| 目的 | Azure利用拡大前に最低限の統制を敷く |

大規模な全社統合基盤ではなく、まずは管理可能な範囲で標準を作り、後から拡張できる構成を想定する。

## 3. 現状課題

想定する現状課題は以下。

| 課題 | 内容 |
|---|---|
| 権限付与のばらつき | 必要以上に広い権限が付与されやすい |
| タグ未整備 | 所有者、用途、コスト集計単位が分かりにくい |
| ログ未設定 | 障害発生後に必要なログが残っていない可能性がある |
| コスト把握の難しさ | Resource GroupやTagの設計が弱く、費用の所在が追いにくい |
| 例外運用の曖昧さ | 標準から外れる設定が理由や期限なしに残りやすい |
| 作業証跡不足 | 何を変更し、どう確認したかが残りにくい |
| 手動作業依存 | 再現性が低く、作業者によるばらつきが出やすい |

これらは、Azure利用初期では大きな問題に見えにくいが、利用範囲が広がると運用負荷や監査対応の負担につながる。

## 4. 設計目標

本構成の設計目標は以下とする。

| 目標 | 内容 |
|---|---|
| 最小限の統制 | 初期段階で必要なPolicy、RBAC、Tag、Logを整理する |
| 再現性 | BicepとRunbookで同じ構成を再現できるようにする |
| 運用しやすさ | 運用担当者が確認、変更、削除を追える状態にする |
| 証跡化 | What-If、Deploy、Policy、RBAC、Log設定の結果を残す |
| 低コスト | 個人検証または小規模検証で扱える範囲にする |
| 拡張性 | 将来的にManagement GroupやHub-Spoke構成へ広げられる余地を残す |

設計の中心は、リソース作成そのものではなく、運用上のばらつきを減らすことである。

## 5. 機能要件

初期版で扱う機能要件は以下。

| 要件ID | 要件 | 内容 |
|---|---|---|
| FR-001 | Resource Group作成 | 共通基盤、監視、検証用のResource Groupを作成できること |
| FR-002 | Tag標準 | 必須タグを定義し、Resource GroupやResourceへ付与できること |
| FR-003 | Policy Assignment | 必須タグ、利用リージョン、Public IP、Diagnostic SettingsなどのPolicyを割り当てられること |
| FR-004 | RBAC Assignment | 想定ロールを想定スコープへ割り当てられること |
| FR-005 | Log Analytics Workspace | 共通ログ出力先を作成できること |
| FR-006 | Diagnostic Settings | 対象リソースのログ出力設定を確認できること |
| FR-007 | What-If | デプロイ前に差分確認ができること |
| FR-008 | Validation | デプロイ後に主要設定を確認できること |
| FR-009 | Teardown | 検証後に対象リソースを削除できること |

## 6. 非機能要件

初期版で扱う非機能要件は以下。

| 要件ID | 要件 | 内容 |
|---|---|---|
| NFR-001 | 再現性 | BicepとCLIで同じ構成を再現できること |
| NFR-002 | 可読性 | 設計意図、実装、Runbook、Evidenceの関係が追えること |
| NFR-003 | 低コスト | 高額なSKUや長時間稼働リソースを前提にしないこと |
| NFR-004 | 安全性 | 破壊的操作はTeardownに分離し、対象確認を前提にすること |
| NFR-005 | 拡張性 | 将来的にManagement Groupや追加Policyへ拡張できること |
| NFR-006 | 機密情報保護 | 実Tenant ID、Subscription ID、ユーザー情報などを含めないこと |
| NFR-007 | 運用引き継ぎ性 | 第三者が設計意図と確認手順を追えること |

## 7. 運用要件

運用面では、以下を要件とする。

| 要件ID | 要件 | 内容 |
|---|---|---|
| OPS-001 | Runbook | What-If、Deploy、Validate、Teardownの手順を用意すること |
| OPS-002 | Evidence | 実行結果と確認結果をMarkdownで残せること |
| OPS-003 | 例外管理 | 標準から外れる設定は理由、期限、承認者を記録すること |
| OPS-004 | 棚卸し | RBAC、Tag、Policy準拠状況を確認できること |
| OPS-005 | 削除確認 | 検証後に不要リソースを削除できること |
| OPS-006 | 手動作業抑制 | 可能な範囲でCLIまたはIaCに寄せること |

## 8. セキュリティ要件

セキュリティ面では、以下を要件とする。

| 要件ID | 要件 | 内容 |
|---|---|---|
| SEC-001 | 最小権限 | RBACは必要最小限のスコープとロールにすること |
| SEC-002 | Public IP確認 | Public IP利用を検出できること |
| SEC-003 | Storage公開設定確認 | Storage Accountの公開設定を確認できること |
| SEC-004 | Key Vault保護設定 | Key Vault利用時に保護設定を確認できること |
| SEC-005 | ログ取得 | 必要なリソースのログ取得状態を確認できること |
| SEC-006 | 機密情報除外 | 公開リポジトリに実環境情報を含めないこと |

## 9. コスト要件

コスト面では、以下を要件とする。

| 要件ID | 要件 | 内容 |
|---|---|---|
| CST-001 | 低コスト検証 | 個人検証環境でも扱える範囲にすること |
| CST-002 | CostCenterタグ | コスト集計単位をタグで確認できること |
| CST-003 | 不要リソース削除 | 検証後にTeardownできること |
| CST-004 | ログ収集量抑制 | Log Analyticsの収集量を必要最小限にすること |
| CST-005 | 高額構成の除外 | 初期版では高額な構成を前提にしないこと |

## 10. 制約条件

本構成の制約条件は以下。

| 項目 | 制約 |
|---|---|
| スコープ | 初期版はSubscription単位を基本とする |
| Management Group | 初期版では必須としない |
| ネットワーク | Hub-Spokeの詳細設計は対象外 |
| 監視 | Alert、通知、Sentinel連携は詳細対象外 |
| ID管理 | Entra IDのライフサイクル管理は対象外 |
| 実装 | BicepとAzure CLIを基本とする |
| 機密情報 | 実環境の識別情報は含めない |
| コスト | 低コスト検証を優先する |

## 11. 初期版で実装する範囲

初期版では、以下を実装対象とする。

| 区分 | 実装対象 |
|---|---|
| IaC | Resource Group、Log Analytics Workspace、Policy Assignment、RBAC Assignment、Tag |
| Runbook | login、set-subscription、what-if、deploy、validate、teardown |
| Evidence | What-If結果、Deployment結果、Policy確認、RBAC確認、Diagnostic Settings確認、Validation Summary |
| Docs | Governance、Policy、RBAC、Tag、Monitoring、Cost、Exception、Validation |

AVD運用標準化は、メインのGovernance Baseline整備後に、サブテーマとして扱う。

## 12. 初期版で実装しない範囲

初期版では、以下は実装しない。

| 区分 | 内容 |
|---|---|
| Enterprise Scale | 複数Management Groupを含む全社Landing Zone |
| Network | 本格的なHub-Spoke、Firewall、Private Endpoint設計 |
| Security | Defender for Cloud、Sentinel、PIMの詳細設計 |
| Monitoring | 本番向けAlert、通知、運用監視体制 |
| Workload | アプリケーションや業務システムの詳細構成 |
| Organization | 実際の承認フロー、変更管理システム連携 |

## 13. 受け入れ条件

初期版の受け入れ条件は以下。

| 条件 | 内容 |
|---|---|
| 設計 | 各設計文書で目的、対象、非対象、確認観点が整理されていること |
| IaC | Bicepで主要リソースと割り当てを表現できること |
| Runbook | Azure CLIでWhat-If、Deploy、Validate、Teardownの流れを説明できること |
| Evidence | 実行結果をMarkdownで残せること |
| セキュリティ | 実環境の機密情報が含まれていないこと |
| コスト | 検証後に削除できる構成であること |

## 14. まとめ

本構成では、Azure利用拡大前に整えるべき最低限のGovernance Baselineを対象とする。

重要なのは、最初から大きな基盤を作ることではなく、権限、タグ、ログ、コスト、例外、証跡を運用可能な単位で整理することである。

この要件をもとに、Policy、RBAC、Tag、Monitoring、Cost、Exception、Validationの各設計へ展開する。