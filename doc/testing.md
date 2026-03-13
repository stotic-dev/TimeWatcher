# テスト

## テストの実行

### fastlane（推奨）

```bash
bundle exec fastlane ios test
```

### xcodebuild

```bash
xcodebuild \
  -workspace TimerWatcherWorkspace.xcworkspace \
  -scheme TimeWatcher \
  -testPlan TimeWatcher \
  -sdk iphonesimulator \
  -configuration Debug \
  -destination "platform=iOS Simulator,OS=17.2,name=iPhone 15 Pro" \
  clean test | xcpretty
```

## テスト構成

| ターゲット | 状態 | 内容 |
|-----------|------|------|
| `TimeWatcherTests` | 有効 | ユニットテスト（並列実行可） |
| `TimeWatcherUITests` | 無効 | スナップショットテスト（手動実行時のみ有効化） |

テストプラン：`TimeWatcher.xctestplan`

## テストの書き方

- テストは `TimeWatcherPrj/TimeWatcherTests/` 配下に配置する
- ソースのディレクトリ構造をテスト側でも踏襲する
- 日付・時刻のモックは `DateDependency` を使う
- テストユーティリティは `Utilities/TestUtilities.swift` を活用する
- CI では `parallel_testing: false`（シミュレータのリソース競合防止）

## テストファイル一覧

| ファイル | 内容 |
|---------|------|
| `MainTimerView/MainTimerViewTest.swift` | タイマー状態・ViewModel のテスト |
| `RootView/OpenUrlViewModelTest.swift` | ディープリンク URL 解析のテスト |
| `TimerWatcherWidgetIntent/TimerStartIntentTest.swift` | ウィジェット開始 Intent のテスト |
| `TimerWatcherWidgetIntent/TimerStopIntentTest.swift` | ウィジェット停止 Intent のテスト |
| `Utilities/TestUtilities.swift` | 日付操作などのテストヘルパー |
