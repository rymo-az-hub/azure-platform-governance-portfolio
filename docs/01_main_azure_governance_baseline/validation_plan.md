# Validation Plan

## 1. 目的

この文書では、Azure Governance Baselineを適用した後の確認計画を整理する。

設計書やBicepを作成しても、実際に意図した状態になっているかを確認しなければ、運用に渡せる状態とは言えない。

本構成では、What-If、Deploy、Policy、RBAC、Tag、Diagnostic Settings、Teardownの確認結果をEvidenceとして残す。

## 2. 基本方針

検証では、以下を基本方針とする。

| 項目 | 方針 |
|---|---|
| 事前確認 | What-Ifで差分を確認する |
| デプロイ | Azure CLIで実行する |
| 確認 | CLI結果をEvidenceとして残す |
| 対象 | 初期版で作成した範囲に絞る |
| 削除 | 検証後にTeardownできることを確認する |
| 機密情報 | Evidenceには実IDや機密情報を残さない |

## 3. 検証対象

初期版では、以下を検証対象とする。

| 対象 | 確認内容 |
|---|---|
| Resource Group | 想定どおり作成されているか |
| Tag | 必須タグが付与されているか |
| Log Analytics Workspace | 作成と設定ができているか |
| Policy Assignment | 想定スコープに割り当てられているか |
| RBAC Assignment | 想定ロールが想定スコープに付与されているか |
| Diagnostic Settings | 対象リソースに設定されているか |
| Teardown | 検証後に削除できるか |

## 4. 事前確認

デプロイ前に、以下を確認する。

- Azure CLIにログインしているか
- 対象Subscriptionが正しいか
- パラメータファイルに実環境の機密情報が含まれていないか
- 作成予定のResource Group名が想定どおりか
- locationが想定どおりか
- What-If結果に想定外の削除や変更がないか

確認コマンド例。

~~~bash
az account show
az deployment sub what-if \
  --location japaneast \
  --template-file infra/main.bicep \
  --parameters infra/parameters/dev.bicepparam
~~~

## 5. デプロイ確認

デプロイはAzure CLIで実行する。

~~~bash
az deployment sub create \
  --location japaneast \
  --template-file infra/main.bicep \
  --parameters infra/parameters/dev.bicepparam
~~~

デプロイ後は、成功したかだけではなく、主要リソースが作成されているかを確認する。

確認結果は以下に記録する。

~~~text
docs/04_evidence/02-deployment-result.md
~~~

## 6. Resource Group確認

Resource Groupの確認。

~~~bash
az group list \
  --query "[].{name:name,location:location,tags:tags}" \
  --output table
~~~

確認観点。

- 想定したResource Groupが作成されているか
- locationが正しいか
- 必須タグが付与されているか
- 不要なResource Groupが作成されていないか

## 7. Tag確認

タグの確認。

~~~bash
az resource list \
  --query "[].{name:name,type:type,resourceGroup:resourceGroup,tags:tags}" \
  --output table
~~~

確認観点。

- Environmentが付与されているか
- Ownerが付与されているか
- CostCenterが付与されているか
- Workloadが付与されているか
- ManagedByが付与されているか
- 表記ゆれがないか

## 8. Policy確認

Policy Assignmentの確認。

~~~bash
az policy assignment list --scope <scope> --output table
~~~

個別Policyの確認。

~~~bash
az policy assignment show \
  --name <assignment-name> \
  --scope <scope>
~~~

準拠状態の確認。

~~~bash
az policy state list --subscription <subscription-id> --output table
~~~

確認観点。

- 想定したPolicyが割り当てられているか
- scopeが正しいか
- effectが想定どおりか
- 既存リソースに想定外の影響がないか
- 非準拠リソースが確認できるか

確認結果は以下に記録する。

~~~text
docs/04_evidence/03-policy-assignment-result.md
~~~

## 9. RBAC確認

RBACの確認。

~~~bash
az role assignment list --scope <scope> --output table
~~~

確認観点。

- 想定したprincipalにロールが付与されているか
- scopeが広すぎないか
- OwnerやContributorが不要に付与されていないか
- Reader権限が確認用途として適切か
- 実ユーザーや実グループIDをEvidenceに残していないか

確認結果は以下に記録する。

~~~text
docs/04_evidence/04-rbac-validation-result.md
~~~

## 10. Monitoring確認

Log Analytics Workspaceの確認。

~~~bash
az monitor log-analytics workspace show \
  --resource-group <resource-group-name> \
  --workspace-name <workspace-name>
~~~

Diagnostic Settingsの確認。

~~~bash
az monitor diagnostic-settings list \
  --resource <resource-id>
~~~

確認観点。

- Workspaceが作成されているか
- Diagnostic Settingsが設定されているか
- 出力先Workspaceが正しいか
- 不要なログカテゴリを収集していないか

確認結果は以下に記録する。

~~~text
docs/04_evidence/05-diagnostic-settings-result.md
~~~

## 11. What-If Evidence

What-If結果は、デプロイ前の差分確認として残す。

確認観点。

- Create対象が想定どおりか
- Modify対象が想定どおりか
- Delete対象が含まれていないか
- 既存リソースへの影響がないか
- パラメータの値が想定どおりか

記録先。

~~~text
docs/04_evidence/01-what-if-result.md
~~~

## 12. Validation Summary

個別確認後、全体の確認結果をまとめる。

記録先。

~~~text
docs/04_evidence/06-validation-summary.md
~~~

記載する内容。

- 検証日
- 対象Subscription
- 対象ブランチまたはCommit
- 実行したRunbook
- 確認結果
- 未確認項目
- 既知の制約
- 次回改善点

## 13. Teardown確認

検証後にリソースを削除できることも確認する。

確認観点。

- 削除対象Resource Groupが正しいか
- 本番や共有環境を含んでいないか
- 削除前に対象一覧を確認したか
- 削除後に残存リソースがないか
- 削除結果をEvidenceに残したか

Teardownは、低コスト検証の前提になるため、デプロイと同じくらい重要である。

## 14. 機密情報の扱い

Evidenceには、以下をそのまま残さない。

- Tenant ID
- Subscription ID
- User Principal Name
- Object ID
- 実IPアドレス
- 顧客名
- 社内システム名
- 実環境のResource名

必要に応じて、マスクする。

例:

| 実値 | 置換例 |
|---|---|
| xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx | `<subscription-id>` |
| user@example.com | `<user-principal-name>` |
| rg-prod-customer-a | `rg-workload-sample` |

## 15. まとめ

Validationでは、デプロイできたことだけでなく、設計どおりの状態になっているかを確認する。

What-If、Deploy、Policy、RBAC、Tag、Monitoring、Teardownの結果をEvidenceとして残すことで、設計、実装、運用確認をつなげる。
