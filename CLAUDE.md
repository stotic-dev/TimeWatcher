# CLAUDE.md

AI アシスタント向けのリファレンスです。詳細は各ドキュメントを参照してください。

## ドキュメント

| ドキュメント | 内容 |
|------------|------|
| [README.md](README.md) | プロジェクト概要・動作環境 |
| [doc/architecture.md](doc/architecture.md) | アーキテクチャ・設計・主要ファイル・規約 |
| [doc/development.md](doc/development.md) | 開発環境セットアップ・ブランチ戦略・ビルド方法 |
| [doc/testing.md](doc/testing.md) | テストの実行方法・テストの書き方 |
| [doc/deployment.md](doc/deployment.md) | fastlane レーン・CI/CD パイプライン・環境変数 |

## クイックリファレンス

```bash
# テスト実行
bundle exec fastlane ios test

# TestFlight 配信
bundle exec fastlane ios beta

# App Store リリース
bundle exec fastlane ios release
```

- プロジェクトは必ず `TimerWatcherWorkspace.xcworkspace` で開く
- コミットメッセージは日本語で書く
- ビルド番号は手動で変更しない（fastlane が自動管理）
