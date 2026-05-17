# Azure Governance / Policy Baseline

このディレクトリには、Azure Governance / Policy Baseline の主要設計資料を配置します。

主対象は、中堅規模の組織がAzure利用を広げる前に整えておきたい、Subscription単位の軽量なガバナンス基盤です。

## 位置づけ

初期PoCでは、Subscriptionスコープを中心に設計・実装します。

Management Groupは作成可能な環境であっても、初期PoCの必須要素にはしません。複数Subscriptionへ同じ統制を展開する段階で、Management GroupスコープのPolicy Assignmentや階層設計を検討します。

## ドキュメント一覧

| ドキュメント | 内容 |
|---|---|
| `requirements.md` | 想定シナリオ、要件、制約、受け入れ条件 |
| `governance_design.md` | Governance Baseline全体の設計 |
| `policy_baseline.md` | 初期Policy、適用方針、Audit-firstの考え方 |
| `rbac_design.md` | RBACモデル、スコープ、権限付与方針 |
| `tagging_standard.md` | 必須Tagと運用方針 |
| `monitoring_logging_design.md` | Log AnalyticsとDiagnostic Settingsの考え方 |
| `cost_management_notes.md` | 低コスト検証と初期コスト管理 |
| `exception_operation.md` | 例外の記録、期限、承認、見直し |
| `validation_plan.md` | What-If、Deploy、Validate、Evidenceの確認計画 |

## 推奨確認順

1. `requirements.md`
2. `governance_design.md`
3. `policy_baseline.md`
4. `rbac_design.md`
5. `tagging_standard.md`
6. `monitoring_logging_design.md`
7. `cost_management_notes.md`
8. `exception_operation.md`
9. `validation_plan.md`

## 設計方針

このBaselineでは、以下を重視します。

- 小さく始めて、後から拡張できること
- PolicyはAudit中心から始めること
- RBACは最小権限とスコープ分離を基本にすること
- Tag、Log、Costを後付けにしないこと
- 例外を理由、期限、承認つきで扱うこと
- What-If、Deploy、Validateの結果をEvidenceとして残すこと

## レビュー観点

このディレクトリでは、次の点を確認します。

- 統制内容が過剰ではなく、初期導入しやすいか
- Policy、RBAC、Tag、Log、Cost、例外、Evidenceがつながっているか
- IaCやRunbookへ落とし込める粒度になっているか
- 運用担当者が後から確認できる構成になっているか
