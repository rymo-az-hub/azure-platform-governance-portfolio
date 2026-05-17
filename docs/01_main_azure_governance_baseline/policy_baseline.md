# Policy Baseline

## 1. 目的

この文書では、Azure環境に適用するPolicy Baselineを整理します。

Policyの目的は、リソース作成を単純に制限することではありません。運用上のばらつきや設定漏れを検出し、Azure利用が広がった場合でも最低限の統制を維持することです。

## 2. 基本方針

初期PoCでは、Subscriptionスコープに対してAudit中心のPolicyを割り当てます。

最初からDenyを多用すると、検証作業や既存運用と衝突しやすくなります。そのため、まずはAuditで逸脱状況を確認し、影響範囲と例外運用を整理したうえでDenyへ移行します。

| 項目 | 方針 |
|---|---|
| 初期適用 | Audit中心 |
| 強制制御 | 影響が明確なものからDenyを検討 |
| 適用単位 | 初期PoCはSubscriptionスコープ |
| Management Group | 将来拡張候補 |
| 例外 | 理由、期限、承認者を記録 |
| 実装 | BicepでPolicy Assignmentを管理 |
| 確認 | Azure CLIで割り当て状態を確認 |

## 3. 対象スコープ

| スコープ | 用途 |
|---|---|
| Management Group | 複数Subscriptionへ展開する場合の拡張候補 |
| Subscription | 初期PoCの基本適用単位 |
| Resource Group | 用途別の検証や例外適用の候補 |
| Resource | 個別のTag、Diagnostic Settings確認 |

初期PoCでは、Management Groupを作成可能な環境であっても必須にはしません。まずはSubscription単位でPolicyの割り当て、確認、Evidence化を行います。

## 4. Policy分類

初期PoCで扱うPolicyは以下です。

| 分類 | 目的 |
|---|---|
| Tag | 所有者、環境、コスト集計単位を明確にする |
| Location | 利用リージョンを管理する |
| Network | 意図しないPublic IP利用を検出する |
| Monitoring | Diagnostic Settings未設定を検出する |
| Security | 公開設定や保護設定の不足を検出する |
| Cost | コスト管理に必要な分類を確認する |

初期実装では、Tag、Location、Public IP、Diagnostic Settingsを優先します。

## 5. 初期Policy一覧

| Policy | 目的 | 初期効果 | 将来候補 |
|---|---|---|---|
| 必須Tag | 所有者、環境、コスト集計単位を確認する | Audit | Deny / Modify |
| 利用可能リージョン | 管理対象外リージョンへの配置を検出する | Audit | Deny |
| Public IP利用 | 意図しないインターネット公開を検出する | Audit | Deny |
| Diagnostic Settings | ログ未設定を検出する | AuditIfNotExists | DeployIfNotExists |
| Storage Account公開設定 | 意図しない公開アクセスを検出する | Audit | Deny |
| Key Vault保護設定 | Soft Delete、Purge Protectionなどを確認する | Audit | Deny |

## 6. Tag Policy

必須Tagは以下を標準とします。

| Tag Key | 用途 |
|---|---|
| Environment | dev / test / prod などの環境区分 |
| Owner | 所有部門または担当チーム |
| CostCenter | コスト集計単位 |
| Workload | ワークロード名 |
| ManagedBy | iac / manual などの管理方法 |

Tagは、障害対応、コスト確認、棚卸しの起点になります。初期PoCではAuditで未設定を検出し、運用に乗せられる段階でDenyまたはModifyを検討します。

## 7. Location Policy

利用可能リージョンは、管理対象リージョンを明確にするために使います。

初期PoCでは `japaneast` や `japanwest` などを候補とします。ただし、サービスによっては利用可能リージョンが限られるため、最初はAuditで影響を確認します。

## 8. Public IP Policy

Public IPはセキュリティ影響が大きいため、作成状況を検出できる状態にします。

初期PoCではAuditから開始します。Denyにする場合は、例外申請の流れと、正当なPublic IP利用の扱いを先に決めます。

## 9. Diagnostic Settings Policy

Diagnostic Settingsは、障害対応や監査対応の前提になります。

初期PoCでは、未設定を検出することを優先します。自動設定まで行う場合は、対象サービス、ログカテゴリ、Log Analytics Workspace、コスト影響を確認したうえでDeployIfNotExistsを検討します。

## 10. Security関連Policy

Storage AccountやKey Vaultは、公開設定や保護設定の不足がリスクにつながりやすい領域です。

初期PoCではAuditで状態を確認し、後続のSecurity Baseline拡張候補として扱います。

## 11. Policy効果の使い分け

| 効果 | 用途 |
|---|---|
| Audit | 逸脱を検出する。初期導入時の基本 |
| Deny | 明確に禁止したい設定を止める |
| Modify | Tag追加など軽微な補正を自動化する場合に使う |
| AuditIfNotExists | 関連設定が存在しないことを検出する |
| DeployIfNotExists | 関連設定を自動作成する場合に使う |

DenyやDeployIfNotExistsは影響が大きいため、初期PoCでは必要最小限にします。

## 12. 例外運用

Policyで検出または制御する場合でも、例外は発生します。

例外を認める場合は、以下を記録します。

| 項目 | 内容 |
|---|---|
| 例外対象 | Resource、Resource Group、Subscriptionなど |
| 例外理由 | なぜ標準に合わせられないか |
| 影響範囲 | セキュリティ、コスト、運用への影響 |
| 承認者 | 誰が例外を認めたか |
| 期限 | いつまで例外とするか |
| 見直し予定 | 再確認するタイミング |

## 13. 実装方針

Policy AssignmentはBicepで管理します。

想定する配置は以下です。

```text
infra/modules/policy/main.bicep
```

初期PoCでは、組み込みPolicyの割り当てを基本にします。カスタムPolicyは、組み込みPolicyで表現できない要件が出た場合に追加します。

パラメータ化する主な項目は以下です。

- Policy assignment名
- 適用スコープ
- allowed locations
- required tag names
- effect
- Log Analytics Workspace ID

## 14. 確認方針

Policy適用後は、Azure CLIで割り当て状態を確認します。

```bash
az policy assignment list --scope <scope>
az policy assignment show --name <assignment-name> --scope <scope>
az policy state list --subscription <subscription-id>
```

確認結果は、`docs/04_evidence/03-policy-assignment-result.md` に記録します。

## 15. 初期PoCで扱わないもの

初期PoCでは以下を扱いません。

- 大量のカスタムPolicy定義
- 複数Management GroupへのPolicy階層展開
- Policy Initiativeの大規模設計
- Defender for Cloudの詳細な規制コンプライアンス設定
- DeployIfNotExistsによる大規模な自動修復
- 既存本番環境への強制適用

## 16. まとめ

Policy Baselineでは、Azure利用が広がる前に最低限確認すべきルールを定義します。

初期PoCではAuditを中心に現状を見える化し、影響範囲と例外運用を確認したうえでDenyやDeployIfNotExistsへ段階的に移行します。

## Resource Groupタグの扱い

現行PoCのRequired Tag Policyは、`mode: Indexed` を前提にしたリソース向けのタグ確認を対象にします。

Resource Groupについては、Bicepデプロイ時にタグを付与し、`Test-GovernanceBaseline.ps1` でタグ状態を確認します。つまり、初期PoCではResource GroupタグをAzure Policyで強制しているのではなく、デプロイ結果とValidateで確認する扱いです。

Resource Group自体のタグをPolicyで厳密に統制する場合は、`mode: All` を使い、対象Resource TypeをResource Groupに絞ったPolicy定義を別途追加する想定です。

この切り分けにより、初期PoCでは以下の範囲に整理します。

| 対象 | 現行PoCでの扱い |
|---|---|
| AzureリソースのRequired Tag | Custom PolicyでAudit |
| Resource Groupのタグ | Bicepで付与しValidateで確認 |
| Resource GroupタグのPolicy強制 | 将来拡張 |
