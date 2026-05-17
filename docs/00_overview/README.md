# Overview

このディレクトリには、リポジトリ全体の前提、構成、設計方針をまとめています。

詳細設計に入る前に、まずこのディレクトリを確認する想定です。

## ドキュメント一覧

| ドキュメント | 内容 |
|---|---|
| `portfolio_scope.md` | 対象読者、想定シナリオ、対象範囲、非対象範囲を整理 |
| `architecture_overview.md` | Azure Governance BaselineとAVD運用標準化の全体構成を整理 |
| `design_principles.md` | 設計時に重視する判断基準を整理 |

## 推奨確認順

1. `portfolio_scope.md`
2. `architecture_overview.md`
3. `design_principles.md`

## このディレクトリの位置づけ

このリポジトリは、単なるAzureリソース作成例やスクリプト集ではありません。

Azure基盤をどう設計し、どう運用へ渡し、どのように確認結果を残すかを示すための構成です。

そのため、このOverviewでは次の点を先に明確にします。

- 何を示すリポジトリか
- どの範囲を対象にするか
- どの範囲を対象外にするか
- Azure Governance BaselineとAVD運用標準化をどう位置づけるか
- 公開資料と非公開メモをどう分けるか
