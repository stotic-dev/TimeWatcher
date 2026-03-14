import Foundation

/// LiveActivityに渡すタイマー状態（ActivityKit非依存）
public struct TimerLiveActivityState {

    /// 経過時間（秒）
    public var timeLapse: TimeInterval
    /// 現在日時
    public var currentDate: Date
    /// 表示用経過時間文字列
    public var timeLapseString: String
    /// タイマーの状態
    public var timerStatus: TimerStatus

    public init(timeLapse: TimeInterval,
                currentDate: Date,
                timeLapseString: String,
                timerStatus: TimerStatus) {

        self.timeLapse = timeLapse
        self.currentDate = currentDate
        self.timeLapseString = timeLapseString
        self.timerStatus = timerStatus
    }
}
