# Tagging Standard

## 1. 目的

この文書では、Azureリソースに付与するタグ標準を整理する。

タグは、単なる分類用のメモではない。所有者確認、環境区分、コスト集計、障害対応、棚卸しの起点になる。

タグがない状態でリソースが増えると、後から誰のリソースか、何の目的で作られたのか、どの費用に紐づくのかを確認する負荷が高くなる。そのため、本構成ではタグを初期設計の一部として扱う。

## 2. 基本方針

タグ設計では、以下を基本方針とする。

| 項目 | 方針 |
|---|---|
| 付与タイミング | リソース作成時に付与する |
| 管理方法 | IaCで指定できるものはIaCで管理する |
| 必須タグ | 最小限に絞る |
| 値の表記 | できるだけ選択式にする |
| 例外 | 理由と期限を残す |
| 確認方法 | PolicyとCLIで確認する |

タグは増やしすぎると運用されなくなる。初期版では、運用上必要なものに絞る。

## 3. 必須タグ

初期版では、以下を必須タグとする。

| Tag Key | 用途 | 例 |
|---|---|---|
| Environment | 環境区分 | dev / test / prod |
| Owner | 所有部門または担当 | platform-team |
| CostCenter | コスト集計単位 | cc-0001 |
| Workload | ワークロード名 | sample-app |
| ManagedBy | 管理方法 | iac / manual |

## 4. Environment

Environmentは、リソースがどの環境に属するかを示す。

| 値 | 用途 |
|---|---|
| dev | 開発、検証 |
| test | 試験、受入 |
| prod | 本番 |
| shared | 共通基盤 |
| sandbox | 個人検証、短期検証 |

Environmentは、コスト確認や変更影響の判断に使う。表記ゆれを避けるため、`development` や `production` のような別表記は使わない。

## 5. Owner

Ownerは、リソースの責任主体を示す。

個人名ではなく、原則としてチーム名や部門名を使う。個人名にすると、異動や退職時にタグがすぐ古くなるためである。

例:

| 推奨 | 非推奨 |
|---|---|
| platform-team | yamada |
| workload-team-a | sato.taro |
| security-team | 個人メールアドレス |

## 6. CostCenter

CostCenterは、コスト集計単位を示す。

実環境では会計上の部門コードやプロジェクトコードを利用することが多い。公開用サンプルでは、実コードではなくダミー値を使う。

例:

~~~text
cc-0001
cc-1001
shared-platform
~~~

## 7. Workload

Workloadは、リソースがどのシステムや用途に属するかを示す。

例:

~~~text
sample-app
platform-monitoring
avd-operations
shared-network
~~~

Workloadがないと、Resource Group名だけに依存した管理になりやすい。将来的にResource Group構成が変わっても追跡できるよう、タグにも用途を残す。

## 8. ManagedBy

ManagedByは、そのリソースがどの方法で管理されているかを示す。

| 値 | 意味 |
|---|---|
| iac | BicepなどIaCで管理 |
| manual | 手動作成または手動管理 |
| imported | 既存リソースを後から管理対象にしたもの |
| external | 外部サービスや別チーム管理 |

`manual` が多い場合、構成の再現性が下がる。初期段階では手動リソースがあってもよいが、最終的にはIaC管理へ寄せる。

## 9. 任意タグ

必要に応じて、以下のタグを追加する。

| Tag Key | 用途 |
|---|---|
| Application | アプリケーション名 |
| DataClassification | データ分類 |
| Criticality | 重要度 |
| ExpireOn | 検証リソースの削除予定日 |
| CreatedBy | 作成主体 |
| ChangeId | 変更管理番号 |

ただし、初期版では任意タグを増やしすぎない。まずは必須タグが確実に付与される状態を優先する。

## 10. タグ付与の単位

タグは、Resource GroupとResourceの両方で考える。

| 対象 | 方針 |
|---|---|
| Resource Group | 基本タグを必ず付与する |
| Resource | Resource Groupから継承できないため、必要に応じて個別付与する |

Azureタグは、Resource Groupに付けてもResourceへ自動継承されるわけではない。そのため、PolicyやIaCで個別リソースにも付与することを考える。

## 11. Policyとの関係

タグ標準は、Azure Policyで確認する。

初期版では、必須タグの未設定をAuditで検出する。

将来的には、以下を検討する。

- タグ未設定リソースのDeny
- Resource Groupからのタグ継承をModifyで補助
- CostCenter未設定のリソース作成制御
- sandbox環境のExpireOn必須化

ただし、ModifyやDenyは影響が大きいため、初期段階ではAuditから始める。

## 12. Bicep実装方針

Bicepでは、共通タグをパラメータ化する。

想定例:

~~~bicep
param commonTags object = {
  Environment: 'dev'
  Owner: 'platform-team'
  CostCenter: 'cc-0001'
  Workload: 'sample-app'
  ManagedBy: 'iac'
}
~~~

各モジュールでは、必要に応じて追加タグをマージする。

~~~bicep
var tags = union(commonTags, additionalTags)
~~~

## 13. Azure CLI確認方針

タグ設定後は、Azure CLIで確認する。

~~~bash
az resource list --query "[].{name:name,type:type,tags:tags}" --output table
az group show --name <resource-group-name> --query tags
~~~

確認結果は、Evidenceに記録する。

## 14. 運用時の確認観点

タグ運用では、以下を確認する。

- 必須タグが付与されているか
- 表記ゆれがないか
- Ownerが個人名になっていないか
- CostCenterが空欄や仮値のままになっていないか
- ManagedByが実態と合っているか
- sandboxリソースに削除予定があるか
- タグ未設定リソースの一覧を定期的に確認しているか

## 15. まとめ

タグは、リソース管理の基本情報である。

初期版では、Environment、Owner、CostCenter、Workload、ManagedByを必須とし、作成時点で付与する。後から整理するのではなく、IaCとPolicyで標準化する。
