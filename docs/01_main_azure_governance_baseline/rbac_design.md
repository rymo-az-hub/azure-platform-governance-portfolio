# RBAC Design

## 1. 目的

この文書では、Azure Governance BaselineにおけるRBAC設計を整理します。

RBACは、作業者に権限を付与するだけの設定ではありません。誰が、どの範囲で、どの操作を行えるのかを明確にし、過剰権限や責任範囲の曖昧さを減らすための設計要素です。

## 2. 基本方針

| 項目 | 方針 |
|---|---|
| 権限付与 | 個人ではなくグループ単位を基本にする |
| スコープ | Subscription全体の権限は最小限にする |
| 通常運用 | Resource Group単位で付与する |
| 強権限 | OwnerやContributorは用途と期限を明確にする |
| 棚卸し | 不要権限を定期的に確認する |
| Evidence | 付与結果と確認結果を残す |

## 3. スコープ設計

| スコープ | 用途 | 初期PoCでの扱い |
|---|---|---|
| Management Group | 複数Subscriptionにまたがる統制 | 将来拡張候補 |
| Subscription | 基盤全体の管理、Policy、監査 | 付与対象を絞って利用 |
| Resource Group | 共通基盤やワークロード運用 | 通常運用の基本単位 |
| Resource | 個別リソースの限定操作 | 必要時のみ利用 |

初期PoCでは、SubscriptionとResource Groupを中心に扱います。Management Groupは、複数Subscriptionへ展開する段階で検討します。

## 4. ロール設計

| 役割 | 想定スコープ | 主な用途 |
|---|---|---|
| Platform Owner | Subscription | ガバナンス設計、基盤管理 |
| Platform Operator | 共通基盤Resource Group | 監視、ログ、共通リソース運用 |
| Workload Owner | Workload Resource Group | 個別ワークロード管理 |
| Workload Operator | Workload Resource Group | 日常運用、状態確認、限定的な変更 |
| Reader / Auditor | Subscription or Resource Group | 監査、確認、レビュー |

公開リポジトリでは、実ユーザーや実グループ名は使わず、サンプル名で表現します。

| サンプルグループ | 想定ロール |
|---|---|
| `grp-az-platform-owners` | Ownerまたは必要最小限の管理ロール |
| `grp-az-platform-operators` | Contributorまたは運用に必要な限定ロール |
| `grp-az-workload-owners` | Workload Resource GroupのContributor |
| `grp-az-auditors` | Reader |

## 5. 主要ロールの扱い

| ロール | 扱い |
|---|---|
| Owner | 権限付与を含む強い権限。Subscription全体への付与は最小限にする |
| Contributor | 多くの変更操作が可能。原則としてResource Group単位で付与する |
| Reader | 監査、レビュー、状態確認に利用する。付与範囲は整理する |

Ownerが必要な場合は、Contributorでは足りない理由、付与期間、承認者、削除確認を明確にします。

## 6. カスタムロール

初期PoCでは、カスタムロールは必須にしません。

まずは組み込みロールで設計し、Contributorでは広すぎるがReaderでは不足する場合に検討します。ただし、カスタムロールを増やしすぎると管理負荷が上がるため、必要性が明確な場合に限定します。

## 7. 一時権限

一時的に強い権限が必要な場合でも、恒久権限として放置しません。

最低限、以下を記録します。

| 項目 | 内容 |
|---|---|
| 対象者またはグループ | 誰に付与するか |
| 付与スコープ | どの範囲に付与するか |
| 付与ロール | どのロールを付与するか |
| 理由 | なぜ必要か |
| 期限 | いつまで必要か |
| 承認者 | 誰が認めたか |
| 削除確認 | 期限後に削除されたか |

PIMの詳細設計は初期PoCの対象外ですが、一時権限の考え方は設計前提に含めます。

## 8. 実装方針

RBAC AssignmentはBicepで管理します。

```text
infra/modules/rbac/main.bicep
```

主なパラメータは以下です。

- `principalId`
- `roleDefinitionId`
- `scope`
- `assignmentName`
- `description`

実Principal IDは公開リポジトリに含めません。必要な場合はパラメータとして渡す設計にします。

## 9. 確認方針

Azure CLIで割り当て状態を確認します。

```bash
az role assignment list --scope <scope> --output table
az role assignment list --assignee <principal-id> --all --output table
```

確認結果は、`docs/04_evidence/04-rbac-validation-result.md` に記録します。

## 10. 運用時の確認観点

- Subscription全体に不要なOwner / Contributorがないか
- 個人へ直接付与していないか
- Resource Group単位で権限を分けられているか
- 退職者、異動者、不要グループが残っていないか
- 一時権限が期限後に削除されているか
- Readerの付与範囲が広すぎないか

## 11. まとめ

RBACでは、作業を通すことよりも、操作範囲と責任範囲を明確にすることを重視します。

初期PoCでは、Subscription全体の強権限を絞り、通常運用はResource Group単位で分離します。
