# Cost Management Notes

## 1. 目的

この文書では、Azure Governance Baselineにおけるコスト管理の初期方針を整理します。

初期PoCでは、本格的なFinOps設計までは扱いません。まずは、どのリソースが、何の目的で、誰の管理で、どの費用単位に紐づいているかを追える状態を作ることを重視します。

## 2. 基本方針

| 項目 | 方針 |
|---|---|
| 集計単位 | Resource GroupとTagを組み合わせる |
| 必須Tag | CostCenter / Environment / Workloadを重視する |
| 検証環境 | 低コストで作成し、不要時は削除する |
| Evidence | 作成結果と削除結果を残す |
| 運用 | 不要リソースの棚卸しを前提にする |

## 3. コスト管理で使う情報

| 情報 | 用途 |
|---|---|
| Resource Group | 用途・ライフサイクル単位の確認 |
| Environment Tag | dev / test / prodなどの環境別確認 |
| CostCenter Tag | 部門・プロジェクト別確認 |
| Workload Tag | システム・用途別確認 |
| Owner Tag | 問い合わせ先、責任主体の確認 |
| ManagedBy Tag | IaC管理か手動管理かの確認 |

Tagが未設定の場合、Cost Management上で集計しづらくなります。そのため、Tag標準とコスト管理はセットで扱います。

## 4. Resource Group設計との関係

Resource Groupは、コスト確認の単位としても使います。

初期PoCでは、以下のように用途を分けます。

| Resource Group | 用途 |
|---|---|
| `rg-apg-<env>-monitoring` | Log Analyticsなど共通監視基盤 |
| `rg-apg-<env>-network` | 最小ネットワーク構成 |
| `rg-apg-<env>-workload-sample` | 検証用ワークロード |

共通基盤とワークロードを同じResource Groupに混ぜると、コストや権限の整理が難しくなります。用途とライフサイクルが近い単位で分けます。

## 5. 低コスト検証の方針

初期PoCでは、個人検証環境でも扱えるように低コストを前提にします。

考慮する点は以下です。

- 高額になりやすいSKUを避ける
- 常時稼働が必要なリソースを増やしすぎない
- 検証後に削除できる構成にする
- ログ収集量を増やしすぎない
- 不要なPublic IPやVMを作成しない
- Teardown手順を用意する

特にLog Analyticsは、収集量が増えるとコストに影響します。初期段階では、必要なログに絞ります。

## 6. 予算とアラート

初期PoCでは、詳細な予算アラート設計は対象外です。

実運用では、以下を検討します。

- Subscription単位の予算
- Resource Group単位の予算
- CostCenter単位の予算
- 月次のしきい値アラート
- 急激なコスト増加の検知

予算アラートは、通知先と対応フローが決まっていて初めて運用に乗ります。PoCでは、まず集計できる状態を優先します。

## 7. Tag未設定時の影響

Tag未設定のリソースが増えると、以下の問題が起きます。

- コストの持ち主が分からない
- 不要リソースを削除してよいか判断しづらい
- 棚卸し時に確認が必要になる
- 環境別、用途別の集計ができない
- 問い合わせ先が分からない

そのため、CostCenter、Environment、Workload、Ownerは初期段階から付与します。

## 8. 確認方針

リソース一覧とTagを確認します。

```bash
az resource list \
  --query "[].{name:name,type:type,resourceGroup:resourceGroup,tags:tags}" \
  --output table
```

Resource GroupのTagを確認します。

```bash
az group list \
  --query "[].{name:name,location:location,tags:tags}" \
  --output table
```

利用量や金額の詳細確認は、契約種別や権限に依存します。初期PoCでは、Evidenceとしてリソース構成とTagを中心に残します。

## 9. Teardown方針

検証環境では、作成後に削除できることを前提にします。

削除時には、以下を確認します。

- 対象Resource Groupが正しいか
- 本番や共有環境を含んでいないか
- 削除対象に想定外リソースがないか
- BackupやLockが残っていないか
- 削除後に残存リソースがないか

Teardownは、単に削除コマンドを実行する作業ではありません。削除前確認と削除後確認まで含めてRunbook化します。

## 10. 運用時の確認観点

- CostCenter Tagが付与されているか
- Environmentごとに確認できるか
- Workloadごとにリソースを追えるか
- 不要な検証リソースが残っていないか
- Log Analyticsの収集量が過剰でないか
- Public IPやVMなど、意図しないコスト要因がないか
- 削除手順とEvidenceが残っているか

## 11. まとめ

初期PoCのコスト管理では、複雑なFinOps運用よりも、まず集計・説明できる状態を作ることを重視します。

Resource Group設計とTag標準を組み合わせ、誰の、何の、どの環境のリソースかを追えるようにします。検証後に削除できることも、コスト管理の一部として扱います。
