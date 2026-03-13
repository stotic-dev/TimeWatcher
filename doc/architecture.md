# アーキテクチャ

## パターン：MVVM + Combine

| 層 | 役割 | 主なファイル |
|----|------|------------|
| Model | タイマーのコアロジック・状態管理 | `TimeWatch.swift` |
| ViewModel | UIに公開する状態・イベント処理 | `MainTimerViewModel.swift` |
| View | SwiftUI による宣言的 UI | `MainTimerView.swift` など |

- ViewModel は `ObservableObject` + `@Published` で状態を公開する
- View はモデルの状態を直接変更しない

## ディレクトリ構成

```
TimeWatcherPrj/
├── TimeWatcher/                 # メインアプリターゲット
│   ├── AppModel/                # ビジネスロジック
│   │   ├── TimeWatch.swift      # タイマーエンジン（シングルトン）
│   │   └── LiviActivity/        # ライブアクティビティ管理
│   ├── View/                    # SwiftUI ビュー
│   │   ├── RootView/            # アプリエントリ・ディープリンク
│   │   ├── MainTimerView/       # タイマー画面 + ViewModel
│   │   └── ViewParts/           # 共通UIコンポーネント
│   ├── Utility/                 # 汎用ユーティリティ
│   │   ├── Extension/           # Date / Calendar / TimeInterval 拡張
│   │   ├── Logger/              # アプリ共通ロガー
│   │   └── Constant/            # AppConstants
│   └── Dependency/              # 依存性注入
├── TimeWatcherWidget/           # ウィジェット拡張ターゲット
│   └── Intent/                  # App Intents（タイマー操作）
├── TimeWatcherTests/            # ユニットテスト
└── TimeWatcherExternalResouce/  # SwiftPackage：デザイントークン
```

## 主要ファイル

| ファイル | 内容 |
|---------|------|
| `TimeWatcher/AppModel/TimeWatch.swift` | タイマーエンジン。Combine Publisher で 0.001秒刻みに状態を配信 |
| `TimeWatcher/View/MainTimerView/MainTimerViewModel.swift` | タイマー状態を UI 向けに変換。最大表示 99時間 |
| `TimeWatcher/AppModel/LiviActivity/LiveActivityManager.swift` | ActivityKit ラッパー。テスト用モックあり |
| `TimeWatcher/Dependency/DateDependency.swift` | 現在時刻の DI。テストで時刻をモック可能にする |
| `TimeWatcherWidget/Intent/TimerStartIntent.swift` | ウィジェットからタイマー開始 |
| `TimeWatcherWidget/Intent/TimerStopIntent.swift` | ウィジェットからタイマー停止 |
| `TimeWatcherExternalResouce/swiftgen.yml` | SwiftGen 設定。カラー・画像をタイプセーフに生成 |

## 設計上の規約

- **シングルトン**：`TimeWatch.shared` のみ。新たな共有状態を増やさない
- **時刻取得**：`Date.now` を直接呼ばず `DateDependency` 経由で取得する
- **リソース参照**：`Asset.Colors.*` / `Asset.Images.*`（SwiftGen 生成）を使い、文字列リテラルは使わない
- **ライブアクティビティ**：タイマー状態が変わるときは必ずライブアクティビティも更新する
- **ウィジェット Intent**：Intent は薄く保ち、ビジネスロジックはモデル層に委譲する
- **ロギング**：`print()` は使わず `logger`（`Logger.swift`）を使う
- **定数**：マジックリテラルを避け `AppConstants.swift` に定義する

## 注意点

- iOS 18 でライブアクティビティの App Intent が動作しない問題の修正が `da0eb9c` に含まれる。この変更を誤って戻さないこと
- SwiftGen で生成されたコードが見つからない場合は `TimeWatcherExternalResouce` ターゲットを先にビルドする
