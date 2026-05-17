# ADR-001: Landing Zone Liteの対象範囲

## Status

Accepted

## Context

Azure Landing Zoneを最初からEnterprise Scale相当で作り込むと、Management Group、複数Subscription、Hub-Spoke、セキュリティ監視、ID運用、運用体制まで含めた広い設計が必要になる。

本リポジトリでは、個人検証環境や小規模導入検討でも再現できることを優先する。そのため、初期版ではSubscription単位で導入できるLightweightなLanding Zoneとして扱う。

## Decision

初期版では、Subscriptionスコープを中心に、以下を対象とする。

- Resource Group構成
- Azure Policy
- RBAC
- Tag標準
- Log Analytics Workspace
- Diagnostic Settingsの確認方針
- Cost管理の基本観点
- 例外運用
- Evidence

Management Groupを前提とした全社階層設計や、本格的なHub-Spokeネットワークは対象外とする。

## Alternatives Considered

| 案 | 判断 |
|---|---|
| Enterprise Scale Landing Zoneを再現する | 範囲が広く、初期版の主題がぼやけるため見送り |
| 単一Resource Groupだけで構成する | Governance設計としては弱いため不採用 |
| Subscription単位の軽量Baselineにする | 初期版として再現性と説明しやすさのバランスがよい |

## Consequences

この判断により、構成は軽くなる一方で、複数SubscriptionやManagement Groupを前提にした高度な統制は扱わない。

将来的に拡張する場合は、Policy AssignmentやRBACのスコープをManagement Groupへ移すことを検討する。
