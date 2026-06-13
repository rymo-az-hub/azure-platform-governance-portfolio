# ADR-004: Monitoring and Diagnostic Settings

## Status

Accepted

## Context

Azure環境では、障害や設定変更が発生した後にログ不足へ気付くことがある。

ログは後から取得できないため、初期段階で出力先と確認方針を決めておく必要がある。

## Decision

初期版では、Log Analytics Workspaceを共通のログ出力先として扱う。

Diagnostic Settingsは、すべてのリソースへ一律に強制するのではなく、対象リソースとログカテゴリを確認しながら適用する。

初期方針は以下とする。

- Log Analytics Workspaceを共通基盤として作成する
- Public Network AccessはPoCの再現性を優先して明示パラメータ化する
- Diagnostic Settingsの有無を確認対象にする
- 必要なログから収集する
- 収集量とコストを確認する
- 設定結果をEvidenceへ残す

現行PoCでは、Log Analytics Workspaceの作成と基本設定の確認までを実装対象とする。Diagnostic Settings詳細適用、Activity Log export、Private Linkによる閉域化は、対象リソース、ログカテゴリ、ネットワーク要件、運用者の確認経路を整理したうえで将来拡張として扱う。

## Alternatives Considered

| 案 | 判断 |
|---|---|
| すべてのログを最初から収集する | コストと確認負荷が増えるため不採用 |
| ログ設定を後回しにする | 障害時に過去ログが残らないため不採用 |
| 必要な範囲から段階的に収集する | 初期版として現実的 |

## Consequences

ログ出力先を標準化することで、障害対応や監査対応の土台を作りやすくなる。

一方で、どのログを取得するかは運用に合わせて継続的に見直す必要がある。
