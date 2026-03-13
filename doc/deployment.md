# デプロイ

## 環境変数のセットアップ

`.env.skel` をコピーして `.env` を作成し、各値を設定する。

```
ASC_KEY_ID=<App Store Connect API キー ID>
ASC_ISSUER_ID=<App Store Connect 発行者 ID>
ASC_KEY_CONTENT=<Base64 エンコードされた .p8 キー>
MATCH_PASSWORD=<Match 暗号化パスワード>
MATCH_KEYCHAIN_PASSWORD=<キーチェーンパスワード>
FASTLANE_USER=<Apple ID メールアドレス>
MATCH_GIT_BASIC_AUTHORIZATION=<Base64 git 認証情報>
ENVIRONMENT=CI
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8
```

## fastlane レーン

| コマンド | 内容 |
|---------|------|
| `fastlane ios test` | ユニットテスト実行 |
| `fastlane ios beta` | TestFlight へビルド＆アップロード（ビルド番号 +0.1） |
| `fastlane ios release` | App Store へビルド＆提出（ビルド番号 +0.01） |
| `fastlane ios upload_beta` | 既存 IPA を TestFlight にアップロード |
| `fastlane ios upload_release` | 既存 IPA を App Store にアップロード |
| `fastlane ios match_development` | 開発用プロビジョニングプロファイル同期 |
| `fastlane ios match_appstore` | App Store 用プロビジョニングプロファイル同期 |

**ビルド番号は手動で編集しない。** fastlane が自動でインクリメントする。

## CI/CD パイプライン（GitHub Actions）

| ファイル | トリガー | 内容 |
|---------|---------|------|
| `ci.yml` | 全ブランチへの PR | ビルド＋テスト（macOS 13 / Xcode 15） |
| `cdBeta.yml` | `release/beta/*` へのプッシュ | TestFlight 配信（Xcode 16） |
| `cdRelease.yml` | `release/store/*` へのプッシュ | App Store リリース（Xcode 16） |
