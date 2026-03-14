/// タイマーの動作状態
public enum TimerStatus: Codable {

    /// 停止中(タイマーリセット済み)
    case initial
    /// 停止中(タイマーリセット前)
    case stop
    /// 開始中
    case start
}

// MARK: - 外部公開用のプロパティ
extension TimerStatus {

    /// 使用可能なタイマーアクション
    public var useableActions: [TimerActionType] {

        return switch self {

        case .initial:
             [.start]

        case .stop:
            [.reset, .start]

        case .start:
            [.reset, .stop]
        }
    }

    /// 経過時間計測中かどうか
    public var isPlaying: Bool {

        return switch self {

        case .initial, .stop:
            false

        case .start:
            true
        }
    }

    /// 状態を表すアイコン名
    public var icon: String {

        return switch self {

        case .initial, .stop:
            "pause.fill"

        case .start:
            "play.fill"
        }
    }
}
