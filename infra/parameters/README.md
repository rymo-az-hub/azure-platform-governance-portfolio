# Parameters

このディレクトリには、Bicepデプロイ用のパラメータファイルを配置します。

## ファイルの位置づけ

| ファイル | 用途 |
|---|---|
| `dev.bicepparam` | 開発・構成確認用のサンプルパラメータ |
| `lowcost-demo.bicepparam` | 公開Evidence取得時に使用した低コストPoC用パラメータ |

## 公開時の注意

以下はパラメータファイルに含めません。

- 実Tenant ID
- 実Subscription ID
- 実Principal ID
- 実UPN
- 顧客名
- 実環境固有のResource名
- シークレット、パスワード、キー

公開用の値は、再現性と安全性を両立するため、サンプル値またはマスク値として扱います。
