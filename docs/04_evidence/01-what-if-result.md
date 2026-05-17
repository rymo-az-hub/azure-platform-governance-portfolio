# What-If Result

## 1. 目的

この文書では、Azure Governance Baselineをデプロイする前に実行したWhat-If結果を記録する。

What-Ifは、実際に変更を入れる前に、作成、変更、削除されるリソースを確認するために使う。想定外の削除や変更が含まれていないことを確認してからDeployへ進む。

## 2. 実行情報

| 項目 | 内容 |
|---|---|
| 実行日 | YYYY-MM-DD |
| 実行者 | `<operator>` |
| 対象Subscription | `<subscription-name>` |
| 対象Subscription ID | `<subscription-id>` |
| Tenant ID | `<tenant-id>` |
| Template | `infra/main.bicep` |
| Parameter | `infra/parameters/dev.bicepparam` |
| Location | `japaneast` |
| Commit | `<commit-sha>` |

## 3. 実行コマンド

~~~powershell
.\scripts\cli\Invoke-WhatIf.ps1 `
  -Location "japaneast" `
  -ParameterFile ".\infra\parameters\dev.bicepparam"
~~~

## 4. 確認観点

| 観点 | 結果 | 備考 |
|---|---|---|
| 作成予定Resource Groupが想定どおりか | 未確認 |  |
| Log Analytics Workspaceが想定どおりか | 未確認 |  |
| Policy Definition / Assignmentが想定どおりか | 未確認 |  |
| RBAC Assignmentが想定どおりか | 未確認 |  |
| 想定外の削除が含まれていないか | 未確認 |  |
| 想定外の変更が含まれていないか | 未確認 |  |

## 5. What-If結果

必要に応じて、出力結果をマスクして貼り付ける。

~~~text
<what-if output>
~~~

## 6. 判断

| 項目 | 判断 |
|---|---|
| Deployへ進めるか | 未判断 |
| 保留事項 |  |
| 次の対応 |  |

## 7. メモ

- 実Subscription ID、Tenant ID、ユーザー名はそのまま残さない
- What-If結果にDeleteが含まれる場合はDeployしない
- 既存リソースへ影響が出る場合は、理由を確認する
