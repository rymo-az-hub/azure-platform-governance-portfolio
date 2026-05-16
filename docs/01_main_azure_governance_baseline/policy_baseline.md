# Policy Baseline

## 1. 目的

この文書では、Azure環境に適用するPolicy Baselineを整理する。

Policyの目的は、単にリソース作成を制限することではない。運用上のばらつきや設定漏れを検出し、Azure利用が広がった場合でも、最低限の統制が効く状態を作ることである。

初期版では、すべてをDenyで強制するのではなく、Auditを中心に現状を見える化する。そのうえで、影響範囲が明確で、例外運用も整理できるものからDenyへ移行する。

## 2. 基本方針

Policy Baselineでは、以下の方針を採用する。

| 項目 | 方針 |
|---|---|
| 初期適用 | Audit中心 |
| 強制制御 | 影響が明確なものからDenyを検討 |
| 適用単位 | Subscriptionを基本とする |
| 例外 | 理由、期限、承認者を残す |
| 実装 | BicepでPolicy Assignmentを管理する |
| 確認 | Azure CLIで割り当て状態と準拠状態を確認する |

最初から厳しく制御しすぎると、検証作業や既存運用と衝突しやすい。そのため、まずはAuditで逸脱状況を確認し、運用上問題ないものから強制に切り替える。

## 3. 対象スコープ

初期版では、Subscriptionスコープを基本とする。

Management Group配下への展開は将来の拡張対象とし、まずは1つのSubscription内で再現できる構成を優先する。

| スコープ | 用途 |
|---|---|
| Subscription | 基本Policyの割り当て、準拠状態の確認 |
| Resource Group | 特定用途の検証、例外適用の検討 |
| Resource | 個別リソースのDiagnostic Settingsやタグ確認 |

## 4. Policy分類

初期版で扱うPolicyは、以下の分類とする。

| 分類 | 目的 |
|---|---|
| Tag | 所有者、環境、コスト集計単位を明確にする |
| Location | 利用リージョンを制御する |
| Network | 意図しないPublic IP利用を検出する |
| Monitoring | Diagnostic Settings未設定を検出する |
| Security | 公開設定や保護設定の不足を検出する |
| Cost | コスト管理に必要なタグや分類を確認する |

このうち、初期実装ではTag、Location、Network、Monitoringを優先する。

## 5. 初期Policy一覧

### 5.1 必須タグ

リソースに必須タグが付与されているかを確認する。

| 項目 | 内容 |
|---|---|
| 目的 | 所有者、環境、コスト集計単位を確認できる状態にする |
| 対象 | Resource GroupまたはResource |
| 初期効果 | Audit |
| 将来効果 | 必要に応じてDenyまたはModifyを検討 |
| 必須タグ | Environment / Owner / CostCenter / Workload / ManagedBy |

タグは、障害対応、コスト確認、棚卸しの起点になる。未設定のままリソースが増えると、後から整理する負荷が大きくなる。

初期段階ではAuditで未設定リソースを確認し、運用に乗せられる段階でDenyまたはModifyを検討する。

### 5.2 利用可能リージョン

許可されたリージョン以外にリソースが作成されていないかを確認する。

| 項目 | 内容 |
|---|---|
| 目的 | 管理対象外リージョンへのリソース配置を防ぐ |
| 対象 | Resource |
| 初期効果 | Audit |
| 将来効果 | Deny候補 |
| 想定リージョン | japaneast / japanwest など |

リージョン制限は、コスト、データ所在地、運用担当範囲に関係する。

ただし、サービスによっては特定リージョンでしか利用できないものもあるため、初期段階ではAuditで影響を確認する。

### 5.3 Public IP利用

Public IPリソースの作成状況を確認する。

| 項目 | 内容 |
|---|---|
| 目的 | 意図しないインターネット公開リソースを検出する |
| 対象 | Microsoft.Network/publicIPAddresses |
| 初期効果 | Audit |
| 将来効果 | Deny候補 |

Public IPは、セキュリティ上の影響が大きいため、原則として用途を明確にする。

初期版では作成自体を即時禁止せず、作成された場合に検出できる状態を優先する。Denyにする場合は、例外申請の流れを先に決める。

### 5.4 Diagnostic Settings

対象リソースにDiagnostic Settingsが設定されているかを確認する。

| 項目 | 内容 |
|---|---|
| 目的 | 障害対応や監査に必要なログを取得できる状態にする |
| 対象 | 対応リソース |
| 初期効果 | AuditIfNotExists |
| 将来効果 | DeployIfNotExistsを検討 |
| 出力先 | Log Analytics Workspace |

Diagnostic Settingsは、障害発生後に未設定だったことに気付いても過去ログを取得できない。

そのため、初期段階から設定有無を確認できる状態にする。自動設定まで行う場合は、対象サービス、ログカテゴリ、コスト影響を確認したうえでDeployIfNotExistsを検討する。

### 5.5 Storage Accountの公開設定

Storage Accountの公開設定を確認する。

| 項目 | 内容 |
|---|---|
| 目的 | 意図しない公開アクセスを防ぐ |
| 対象 | Microsoft.Storage/storageAccounts |
| 初期効果 | Audit |
| 将来効果 | Deny候補 |

Storage Accountは、設定によってはデータ公開リスクにつながる。

初期版ではAuditで設定状況を確認し、運用上問題がなければDenyへ移行する。

### 5.6 Key Vaultの保護設定

Key Vaultを利用する場合、保護設定が有効になっているかを確認する。

| 項目 | 内容 |
|---|---|
| 目的 | シークレットや鍵の削除リスクを下げる |
| 対象 | Microsoft.KeyVault/vaults |
| 初期効果 | Audit |
| 将来効果 | Deny候補 |
| 確認観点 | Soft Delete / Purge Protection / Public Network Access |

Key Vaultは初期実装の主役ではないが、将来的なSecurity Baselineに接続しやすい領域として扱う。

## 6. 初期実装の優先順位

初期版では、以下の順に実装する。

| 優先度 | Policy | 理由 |
|---|---|---|
| 1 | 必須タグ | コスト、所有者、棚卸しに直結する |
| 2 | 利用可能リージョン | 管理範囲を明確にしやすい |
| 3 | Public IP利用 | セキュリティ影響が大きい |
| 4 | Diagnostic Settings | 障害対応、監査対応の前提になる |
| 5 | Storage Account公開設定 | データ公開リスクの確認に使える |
| 6 | Key Vault保護設定 | Security Baselineの拡張候補として扱う |

最初からすべてを作り込むのではなく、まずはTag、Location、Public IP、Diagnostic Settingsを中心に作成する。

## 7. Policy効果の使い分け

Policy効果は、以下の考え方で使い分ける。

| 効果 | 用途 |
|---|---|
| Audit | 逸脱を検出する。初期導入時の基本 |
| Deny | 明確に禁止したい設定を止める |
| Modify | タグ追加など、軽微な補正を自動化する場合に使う |
| AuditIfNotExists | 関連設定が存在しないことを検出する |
| DeployIfNotExists | 関連設定を自動作成する場合に使う |

初期版では、AuditとAuditIfNotExistsを中心にする。

DenyやDeployIfNotExistsは便利だが、影響範囲が大きい。導入する場合は、事前に対象サービス、例外、ロール権限、既存リソースへの影響を確認する。

## 8. 例外運用

Policyで検出または制御する場合でも、例外は発生する。

例外を認める場合は、以下を記録する。

| 項目 | 内容 |
|---|---|
| 例外対象 | リソース、Resource Group、Subscriptionなど |
| 例外理由 | なぜ標準に合わせられないか |
| 影響範囲 | セキュリティ、コスト、運用への影響 |
| 承認者 | 誰が例外を認めたか |
| 期限 | いつまで例外とするか |
| 見直し予定 | 再確認するタイミング |

例外は、標準からの逸脱である。恒久運用にならないよう、期限と見直し予定を残す。

## 9. Bicep実装方針

Policy Assignmentは、Bicepで管理する。

想定する構成は以下とする。

```text
infra/modules/policy/
└─ main.bicep
```

初期版では、組み込みPolicyを中心に利用する。カスタムPolicyは、組み込みPolicyで表現できない要件が出た場合に追加する。

Bicepでは、以下をパラメータ化する。

- Policy assignment名
- 適用スコープ
- allowed locations
- required tag names
- effect
- Log Analytics Workspace ID

実装時には、Policy定義とPolicy割り当てを混同しない。初期版では、既存の組み込みPolicyを割り当てる構成を基本とする。

## 10. Azure CLI確認方針

Policy適用後は、Azure CLIで以下を確認する。

```bash
az policy assignment list --scope <scope>
az policy state list --subscription <subscription-id>
az policy assignment show --name <assignment-name> --scope <scope>
```

確認結果は、Evidenceとして保存する。

想定するEvidenceは以下とする。

```text
docs/04_evidence/03-policy-assignment-result.md
```

## 11. 運用時の確認観点

Policyを割り当てた後は、以下を確認する。

- 想定したスコープに割り当てられているか
- effectが意図した値になっているか
- 既存リソースへの影響がないか
- 検出結果に想定外のリソースが含まれていないか
- 例外対象を分けられるか
- Denyへ移行できるものがあるか
- 運用担当者が確認できる形になっているか

Policyは一度割り当てて終わりではなく、準拠状況を見ながら調整する。

## 12. 初期版で扱わないもの

初期版では、以下は扱わない。

- 大量のカスタムPolicy定義
- 複数Management GroupへのPolicy階層展開
- Policy initiativeの大規模設計
- Microsoft Defender for Cloudの詳細な規制コンプライアンス設定
- DeployIfNotExistsによる大規模な自動修復
- 既存本番環境への強制適用

これらは重要だが、最初のBaselineとしては範囲が広い。初期版では、読み手が設計意図と実装範囲を追いやすいことを優先する。

## 13. まとめ

Policy Baselineでは、Azure利用が広がる前に、最低限確認すべきルールを定義する。

初期段階では、Auditを中心に現状を見える化し、影響範囲を確認したうえでDenyやDeployIfNotExistsへ段階的に移行する。

重要なのは、Policyを多く割り当てることではなく、運用上必要なルールを選び、例外とEvidenceまで含めて管理できる状態にすることである。
