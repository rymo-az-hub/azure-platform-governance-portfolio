# RBAC Design

## 1. 目的

この文書では、Azure環境におけるRBAC設計の考え方を整理する。

RBACは、単に作業者へ権限を付与するための仕組みではない。誰が、どの範囲で、どの操作を行えるのかを明確にし、過剰権限や責任範囲の曖昧さを減らすための設計要素である。

本構成では、最小権限とスコープ分離を基本とする。便利だからという理由でSubscription全体にOwnerやContributorを広く付与する運用は避ける。

## 2. 基本方針

RBAC設計では、以下を基本方針とする。

| 項目 | 方針 |
|---|---|
| 権限付与 | 個人ではなくグループ単位を基本とする |
| スコープ | Subscription全体の権限は最小限にする |
| 運用権限 | Resource Group単位で付与する |
| 恒久権限 | 必要最小限に絞る |
| 一時権限 | 承認と期限を前提にする |
| 棚卸し | 定期的に不要権限を確認する |
| Evidence | 付与結果と確認結果を残す |

RBACは、一度付与すると放置されやすい。設計時点で、付与だけでなく棚卸しと削除まで考慮する。

## 3. スコープの考え方

RBACは、付与するスコープによって影響範囲が大きく変わる。

| スコープ | 用途 | 注意点 |
|---|---|---|
| Management Group | 複数Subscriptionにまたがる統制 | 初期版では対象外 |
| Subscription | 基盤全体の管理 | 付与対象を絞る |
| Resource Group | ワークロードや共通基盤の運用 | 初期版の基本単位 |
| Resource | 個別リソースの限定操作 | 管理が細かくなりすぎる場合がある |

初期版では、SubscriptionとResource Groupを中心に扱う。

Subscriptionには、基盤管理者や監査担当など、限られた役割だけを付与する。通常の運用作業は、Resource Group単位で分離する。

## 4. ロール設計

初期版では、以下の役割を想定する。

| 役割 | 想定スコープ | 主な用途 |
|---|---|---|
| Platform Owner | Subscription | 基盤全体の管理、Policy、RBAC、共通設定の管理 |
| Platform Operator | 共通基盤Resource Group | 監視、ログ、共通リソースの運用 |
| Workload Owner | Workload Resource Group | 個別ワークロードの管理 |
| Workload Operator | Workload Resource Group | 日常運用、状態確認、限定的な変更 |
| Reader / Auditor | SubscriptionまたはResource Group | 監査、確認、レビュー |

実装時は、実ユーザーや実グループ名ではなく、サンプルグループ名で表現する。

例:

| サンプルグループ | 想定ロール |
|---|---|
| grp-az-platform-owners | Ownerまたは必要最小限の管理ロール |
| grp-az-platform-operators | Contributorまたは運用に必要な限定ロール |
| grp-az-workload-owners | Workload Resource GroupのContributor |
| grp-az-auditors | Reader |

## 5. Owner / Contributor / Readerの扱い

### 5.1 Owner

Ownerは、権限付与を含む強い権限を持つ。Subscription全体へのOwner付与は、最小限にする。

Ownerを付与する場合は、以下を確認する。

- 本当に権限付与操作が必要か
- Contributorでは足りない理由があるか
- 付与期間は恒久か一時か
- 棚卸し対象に含まれているか

### 5.2 Contributor

Contributorは、多くのリソース操作が可能なため、運用上は便利である。一方で、範囲を広く付与すると、変更影響も大きくなる。

Contributorは、原則としてResource Group単位で付与する。

### 5.3 Reader

Readerは、監査、レビュー、確認作業に使いやすい。運用担当者以外にも、状況確認が必要な関係者へ付与しやすい。

ただし、Readerでも構成情報を閲覧できるため、付与対象は整理する。

## 6. カスタムロールの考え方

初期版では、カスタムロールは必須としない。

まずは組み込みロールで設計し、どうしても権限が広すぎる場合にカスタムロールを検討する。

カスタムロールを検討する条件は以下とする。

- Contributorでは権限が広すぎる
- Readerでは作業できない
- 特定操作だけを許可したい
- 複数担当者に同じ限定権限を付与したい
- 権限の説明責任を明確にしたい

ただし、カスタムロールを増やしすぎると管理負荷が上がる。初期段階では、必要性が明確な場合に限定する。

## 7. 一時権限の考え方

一時的に強い権限が必要になる場合はある。

その場合も、恒久権限として付与しない。少なくとも以下を記録する。

| 項目 | 内容 |
|---|---|
| 対象者またはグループ | 誰に付与するか |
| 付与スコープ | どの範囲に付与するか |
| 付与ロール | どのロールを付与するか |
| 理由 | なぜ必要か |
| 期限 | いつまで必要か |
| 承認者 | 誰が認めたか |
| 削除確認 | 期限後に削除されたか |

本リポジトリではPIMの詳細設計までは扱わないが、一時権限の考え方自体は前提に含める。

## 8. Bicep実装方針

RBAC Assignmentは、Bicepで管理する。

想定する配置は以下とする。

~~~text
infra/modules/rbac/
└─ main.bicep
~~~

Bicepでは、以下をパラメータ化する。

- principalId
- roleDefinitionId
- scope
- assignmentName
- description

初期版では、実ユーザーや実グループのIDは含めない。サンプル値またはパラメータ指定とし、公開リポジトリに実環境のIDを残さない。

## 9. Azure CLI確認方針

RBAC設定後は、Azure CLIで割り当て状態を確認する。

~~~bash
az role assignment list --scope <scope> --output table
az role assignment list --assignee <principal-id> --all --output table
~~~

確認結果は、以下に記録する。

~~~text
docs/04_evidence/04-rbac-validation-result.md
~~~

## 10. 運用時の確認観点

RBAC運用では、以下を確認する。

- Subscription全体に不要なOwner / Contributorがないか
- 個人へ直接権限を付与していないか
- Resource Group単位で権限を分けられているか
- 退職者、異動者、不要グループが残っていないか
- 一時権限が期限後に削除されているか
- Reader権限の付与範囲が広すぎないか
- Evidenceとして確認結果が残っているか

## 11. まとめ

RBACは、作業を通すためだけの設定ではなく、責任分界を明確にするための設計要素である。

初期版では、Subscription全体の権限を絞り、通常運用はResource Group単位で分離する。個人付与ではなくグループ付与を基本とし、付与後の棚卸しまで含めて運用する。
