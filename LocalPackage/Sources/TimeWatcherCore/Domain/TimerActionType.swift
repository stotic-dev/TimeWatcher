/// タイマー操作のボタンの動作を定義
public enum TimerActionType {

    /// 開始のアクション
    case start

    /// 停止のアクション
    case stop

    /// リセットのアクション
    case reset
}

// MARK: - 外部公開用のプロパティ定義
extension TimerActionType {

    public var buttonTitle: String {

        switch self {

        case .start:
            "Start"

        case .stop:
            "Stop"

        case .reset:
            "Reset"
        }
    }

    public var buttonIconName: String {

        switch self {

        case .start:
            "play.fill"

        case .stop:
            "pause.fill"

        case .reset:
            "xmark"
        }
    }
}
