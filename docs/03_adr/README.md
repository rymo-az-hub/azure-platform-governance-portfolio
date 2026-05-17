# Architecture Decision Records

このディレクトリには、設計判断の記録を配置します。

ADRは、採用した設計の理由、検討した代替案、受け入れた制約を後から確認できるようにするための文書です。詳細な手順は、設計書またはRunbook側に記載します。

## ADR一覧

| ADR | 判断 |
|---|---|
| `adr-001-landing-zone-lite-scope.md` | 初期PoCではSubscription単位の軽量なLanding Zone Liteとして扱う |
| `adr-002-governance-policy-baseline.md` | Azure Governance / Policy Baselineを主テーマにする |
| `adr-003-rbac-model.md` | RBACは最小権限とスコープ分離を基本にする |
| `adr-004-monitoring-and-diagnostic-settings.md` | Log Analytics WorkspaceとDiagnostic Settingsを初期ログ基盤にする |
| `adr-005-avd-operations-standardization.md` | AVD運用標準化をサブテーマとして扱う |

## 記載方針

各ADRでは、以下を記載します。

- Status
- Context
- Decision
- Alternatives Considered
- Consequences

## レビュー観点

- なぜその判断をしたか
- どの代替案を見送ったか
- どの制約を受け入れたか
- 何を対象外にしたか
- 設計、運用、Evidenceとどうつながるか

## 注意点

ADRは短く保ちます。

判断理由やトレードオフを記録する場所であり、詳細な作業手順やコマンドを記載する場所ではありません。
