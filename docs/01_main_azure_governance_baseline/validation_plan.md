# Validation Plan

## 1. 目的

この文書では、Azure Governance Baselineを適用した後の確認計画を整理します。

設計書やBicepを作成しても、実際に意図した状態になっているかを確認しなければ、運用に渡せる状態とは言えません。初期PoCでは、What-If、Deploy、Policy、RBAC、Tag、Diagnostic Settings、Teardownの結果をEvidenceとして残します。

## 2. 基本方針

| 項目 | 方針 |
|---|---|
| 事前確認 | What-Ifで差分を確認する |
| デプロイ | Azure CLI Runbookで実行する |
| 確認 | CLI結果をEvidenceとして残す |
| 対象 | 初期PoCで作成した範囲に絞る |
| 削除 | 検証後にTeardownできることを確認する |
| 機密情報 | Evidenceに実IDや機密情報を残さない |

## 3. 検証対象

| 対象 | 確認内容 |
|---|---|
| Resource Group | 想定どおり作成されているか |
| Tag | 必須Tagが付与されているか |
| Log Analytics Workspace | 作成と基本設定ができているか |
| Policy Assignment | 想定スコープに割り当てられているか |
| RBAC Assignment | 想定ロールが想定スコープに付与されているか |
| Diagnostic Settings | 対象リソースに設定されているか |
| Teardown | 検証後に削除できるか |

## 4. 事前確認

デプロイ前に以下を確認します。

- Azure CLIにログインしているか
- 対象Subscriptionが正しいか
- パラメータファイルに実環境の機密情報が含まれていないか
- 作成予定のResource Group名が想定どおりか
- Locationが想定どおりか
- What-If結果に想定外の削除や変更がないか

確認コマンド例です。

```bash
az account show
az deployment sub what-if \
  --location japaneast \
  --template-file infra/main.bicep \
  --parameters infra/parameters/dev.bicepparam
```

記録先は `docs/04_evidence/01-what-if-result.md` です。

## 5. デプロイ確認

デプロイはAzure CLIで実行します。

```bash
az deployment sub create \
  --location japaneast \
  --template-file infra/main.bicep \
  --parameters infra/parameters/dev.bicepparam
```

デプロイ後は、成功したかだけではなく、主要リソースが想定どおり作成されているかを確認します。

記録先は `docs/04_evidence/02-deployment-result.md` です。

## 6. Resource Group / Tag確認

Resource Groupを確認します。

```bash
az group list \
  --query "[].{name:name,location:location,tags:tags}" \
  --output table
```

Tagを確認します。

```bash
az resource list \
  --query "[].{name:name,type:type,resourceGroup:resourceGroup,tags:tags}" \
  --output table
```

確認観点は以下です。

- 想定したResource Groupが作成されているか
- Locationが正しいか
- 必須Tagが付与されているか
- 表記ゆれがないか
- 不要なResource GroupやResourceが作成されていないか

## 7. Policy確認

Policy Assignmentを確認します。

```bash
az policy assignment list --scope <scope> --output table
az policy assignment show --name <assignment-name> --scope <scope>
az policy state list --subscription <subscription-id> --output table
```

確認観点は以下です。

- 想定したPolicyが割り当てられているか
- Scopeが正しいか
- Effectが想定どおりか
- 既存リソースに想定外の影響がないか
- 非準拠リソースが確認できるか

記録先は `docs/04_evidence/03-policy-assignment-result.md` です。

## 8. RBAC確認

RBACを確認します。

```bash
az role assignment list --scope <scope> --output table
```

確認観点は以下です。

- 想定したPrincipalにロールが付与されているか
- Scopeが広すぎないか
- OwnerやContributorが不要に付与されていないか
- Reader権限が確認用途として適切か
- 実ユーザーや実グループIDをEvidenceに残していないか

記録先は `docs/04_evidence/04-rbac-validation-result.md` です。

## 9. Monitoring確認

Log Analytics Workspaceを確認します。

```bash
az monitor log-analytics workspace show \
  --resource-group <resource-group-name> \
  --workspace-name <workspace-name>
```

Diagnostic Settingsを確認します。

```bash
az monitor diagnostic-settings list \
  --resource <resource-id>
```

確認観点は以下です。

- Workspaceが作成されているか
- Diagnostic Settingsが設定されているか
- 出力先Workspaceが正しいか
- 不要なログカテゴリを収集していないか

記録先は `docs/04_evidence/05-diagnostic-settings-result.md` です。

## 10. Validation Summary

個別確認後、全体の確認結果をまとめます。

記録先は `docs/04_evidence/06-validation-summary.md` です。

記載する内容は以下です。

- 検証日
- 対象Subscription
- 対象Commit
- 実行したRunbook
- 確認結果
- 未確認項目
- 既知の制約
- 次回改善点

## 11. Teardown確認

検証後にリソースを削除できることも確認します。

確認観点は以下です。

- 削除対象Resource Groupが正しいか
- 本番や共有環境を含んでいないか
- 削除前に対象一覧を確認したか
- 削除後に残存リソースがないか
- 削除結果をEvidenceに残したか

Teardownは、低コスト検証の前提になるため、デプロイと同じくらい重要です。

## 12. 機密情報の扱い

Evidenceには、以下をそのまま残しません。

- Tenant ID
- Subscription ID
- User Principal Name
- Object ID
- 実IPアドレス
- 顧客名
- 社内システム名
- 実環境のResource名

必要に応じて、以下のように置き換えます。

| 実値 | 置換例 |
|---|---|
| `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` | `<subscription-id>` |
| `user@example.com` | `<user-principal-name>` |
| `rg-prod-customer-a` | `rg-workload-sample` |

## 13. まとめ

Validationでは、デプロイできたことだけではなく、設計どおりの状態になっているかを確認します。

What-If、Deploy、Policy、RBAC、Tag、Monitoring、Teardownの結果をEvidenceとして残すことで、設計、実装、運用確認をつなげます。
