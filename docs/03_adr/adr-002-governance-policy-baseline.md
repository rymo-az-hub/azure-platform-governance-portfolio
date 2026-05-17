# ADR-002: Governance / Policy Baselineを主軸にする

## Status

Accepted

## Context

Azure環境は、リソースを作るだけであれば比較的早く始められる。一方で、利用が広がると、権限、タグ、ログ、コスト、例外運用が後追いになりやすい。

特に中堅規模の組織では、最初から大規模な統制基盤を作るよりも、最低限のルールを早い段階で決めておく方が運用に乗せやすい。

## Decision

本リポジトリでは、ネットワークや個別ワークロードの詳細設計よりも、Governance / Policy Baselineを主軸にする。

初期版で重視する対象は以下とする。

- Azure Policy
- RBAC
- Tag標準
- Diagnostic Settings
- Log Analytics
- Cost管理の基本観点
- 例外運用
- Evidence

Policyは、初期段階ではAudit中心で設計する。Denyは、影響範囲と例外運用を確認したうえで段階的に検討する。

## Alternatives Considered

| 案 | 判断 |
|---|---|
| ネットワーク設計を主軸にする | 重要だが、今回の主題である運用統制から外れやすい |
| AVD運用を主軸にする | 実務色は出るが、Azure基盤全体の設計としては狭く見える |
| Governance / Policyを主軸にする | Azure基盤の標準化とCloudOps改善を説明しやすい |

## Consequences

Governanceを主軸にすることで、Azure環境を継続的に管理する考え方を示しやすくなる。

一方で、個別サービスの深い構成例は初期版では少なくなる。そのため、AVD運用標準化はサブテーマとして別に扱う。
