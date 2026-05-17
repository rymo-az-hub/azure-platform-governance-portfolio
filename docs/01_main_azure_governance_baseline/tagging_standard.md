# Tagging Standard

## 1. 目的

この文書では、Azureリソースに付与するTag標準を整理します。

Tagは分類用のメモではなく、所有者確認、環境区分、コスト集計、障害対応、棚卸しの起点です。リソースが増えてから後付けで整理すると負荷が大きくなるため、初期設計に含めます。

## 2. 基本方針

| 項目 | 方針 |
|---|---|
| 付与タイミング | リソース作成時に付与する |
| 管理方法 | IaCで指定できるものはIaCで管理する |
| 必須Tag | 運用上必要な最小限に絞る |
| 値の表記 | できるだけ選択式にする |
| 例外 | 理由と期限を残す |
| 確認方法 | PolicyとAzure CLIで確認する |

Tagは増やしすぎると運用されにくくなります。初期PoCでは、まず必須Tagを確実に付与できる状態を優先します。

## 3. 必須Tag

| Tag Key | 用途 | 例 |
|---|---|---|
| Environment | 環境区分 | dev / test / prod / shared / sandbox |
| Owner | 所有部門または担当チーム | platform-team |
| CostCenter | コスト集計単位 | cc-0001 |
| Workload | ワークロード名 | sample-app |
| ManagedBy | 管理方法 | iac / manual |

## 4. 各Tagの考え方

### Environment

環境区分を示します。

表記ゆれを避けるため、`dev`、`test`、`prod`、`shared`、`sandbox` のように短い値へ統一します。

### Owner

責任主体を示します。

個人名ではなく、チーム名や部門名を基本にします。個人名にすると、異動や退職で情報が古くなりやすいためです。

### CostCenter

コスト集計単位を示します。

公開用サンプルでは、実際の会計コードではなく `cc-0001` のようなダミー値を使います。

### Workload

リソースがどのシステムや用途に属するかを示します。

Resource Group名だけに依存せず、Tagでも用途を追えるようにします。

### ManagedBy

管理方法を示します。

| 値 | 意味 |
|---|---|
| iac | BicepなどIaCで管理 |
| manual | 手動作成または手動管理 |
| imported | 既存リソースを後から管理対象にしたもの |
| external | 外部サービスまたは別チーム管理 |

## 5. 任意Tag

必要に応じて、以下を追加します。

| Tag Key | 用途 |
|---|---|
| Application | アプリケーション名 |
| DataClassification | データ分類 |
| Criticality | 重要度 |
| ExpireOn | 検証リソースの削除予定日 |
| CreatedBy | 作成主体 |
| ChangeId | 変更管理番号 |

任意Tagは、初期PoCでは増やしすぎません。まず必須Tagの定着を優先します。

## 6. 付与単位

| 対象 | 方針 |
|---|---|
| Resource Group | 基本Tagを必ず付与する |
| Resource | 必要に応じて個別付与する |

Azureでは、Resource Groupに付けたTagがResourceへ自動継承されるわけではありません。そのため、IaCやPolicyでResource側のTagも確認します。

## 7. Policyとの関係

初期PoCでは、必須Tagの未設定をAuditで検出します。

将来的には、以下を検討します。

- Tag未設定リソースのDeny
- Resource GroupからのTag継承をModifyで補助
- CostCenter未設定の作成制御
- sandbox環境のExpireOn必須化

DenyやModifyは影響があるため、まずはAuditで現状を確認します。

## 8. Bicep実装方針

共通Tagはパラメータ化します。

```bicep
param commonTags object = {
  Environment: 'dev'
  Owner: 'platform-team'
  CostCenter: 'cc-0001'
  Workload: 'sample-app'
  ManagedBy: 'iac'
}
```

各モジュールでは、必要に応じて追加Tagをマージします。

```bicep
var tags = union(commonTags, additionalTags)
```

## 9. 確認方針

Azure CLIでTagを確認します。

```bash
az resource list --query "[].{name:name,type:type,tags:tags}" --output table
az group show --name <resource-group-name> --query tags
```

確認結果は、Evidenceへ反映します。

## 10. 運用時の確認観点

- 必須Tagが付与されているか
- 表記ゆれがないか
- Ownerが個人名になっていないか
- CostCenterが空欄や仮値のままになっていないか
- ManagedByが実態と合っているか
- sandboxリソースに削除予定があるか
- Tag未設定リソースを定期的に確認しているか

## 11. まとめ

Tagは、Azureリソースを運用で追うための基本情報です。

初期PoCでは、Environment、Owner、CostCenter、Workload、ManagedByを必須とし、IaCとPolicyで標準化します。
