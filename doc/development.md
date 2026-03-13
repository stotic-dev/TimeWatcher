# 開発ワークフロー

## 環境要件

| ツール | バージョン |
|-------|-----------|
| Xcode | 15（CI） / 16（CD） |
| iOS SDK | 17.0+ |
| Ruby | Gemfile で管理 |
| Swift | 5.9+ |

## プロジェクトの開き方

**必ずワークスペースを開くこと。** `.xcodeproj` を直接開くと `TimeWatcherExternalResouce` パッケージが認識されない。

```
TimerWatcherWorkspace.xcworkspace
```

## Ruby 依存パッケージのインストール

```bash
bundle install
```

## ブランチ戦略

| ブランチパターン | 用途 |
|--------------|------|
| `master` | メイン開発ブランチ |
| `release/beta/*` | TestFlight 配信トリガー |
| `release/store/*` | App Store リリーストリガー |
| `claude/*` | AI 支援作業ブランチ |

`main` / `master` への直プッシュは禁止。PR 経由でマージする。

## ビルド（CLI）

```bash
xcodebuild \
  -workspace TimerWatcherWorkspace.xcworkspace \
  -scheme TimeWatcher \
  -sdk iphonesimulator \
  -configuration Debug \
  -destination "platform=iOS Simulator,OS=17.2,name=iPhone 15 Pro" \
  clean build
```
