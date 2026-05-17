# ADR-001: Landing Zone Liteの対象範囲

## Status

Accepted

## Context

Azure Landing Zoneを最初からEnterprise Scale相当で作り込むと、Management Group、複数Subscription、Hub-Spoke、セキュリティ監視、ID運用、運用体制まで含めた広い設計が必要になる。

現在の検証環境ではManagement Groupの作成も可能だが、初期版では再現性と検証しやすさを優先する。そのため、PoCではSubscription単位で導入できる軽量なLanding Zoneとして扱う。

## Decision

初期版のPoCでは、Subscriptionスコープを中心に以下を対象とする。

- Resource Group構成
- Azure Policy
- RBAC
- Tag標準
- Log Analytics Workspace
- Diagnostic Settingsの確認方針
- Cost管理の基本観点
- 例外運用
- Evidence

Management Groupは、初期PoCの必須要素にはしない。

ただし、Management Groupを作成できる環境では、将来的な拡張先として扱う。特に、複数Subscriptionへ同じPolicyやRBAC方針を展開する場合は、Management GroupスコープでのPolicy Assignmentや階層設計を検討する。

## Alternatives Considered

| 案 | 判断 |
|---|---|
| Enterprise Scale Landing Zoneを再現する | 範囲が広く、初期版の主題がぼやけるため見送り |
| Management Groupスコープを初期PoCに含める | 実装範囲が広がるため、初期版では見送り |
| Subscription単位の軽量Baselineにする | 初期版として再現性と説明しやすさのバランスがよい |

## Consequences

この判断により、初期PoCは軽量に保てる。

一方で、複数Subscriptionを前提とした統制や、Management Group階層を使った全社展開は初期版では扱わない。

PoC後の拡張候補として、以下を検討する。

- Management Group階層の設計
- Management GroupスコープのPolicy Assignment
- Subscriptionごとの差分管理
- 例外Subscriptionの扱い
- Management GroupとSubscriptionの責任分界
