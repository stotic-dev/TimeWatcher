#if os(iOS)
import ActivityKit
import Foundation

public struct TimeWatcherWidgetAttributes: ActivityAttributes {

    public struct ContentState: Codable, Hashable {

        public init(timeLapse: TimeInterval, currentDate: Date, timeLapseString: String, timerStatus: TimerStatus) {

            let minusMilliSec = Calendar.current.date(byAdding: -timeLapse.milliSec,
                                                      to: currentDate)
            let startRangeDate = Calendar.current.date(byAdding: [
                .hour: -timeLapse.hour,
                .minute: -timeLapse.minute,
                .second: -timeLapse.seconds
            ],
                                                       to: minusMilliSec)
            let endRangeDate = Calendar.current.date(byAdding: .hour,
                                                     value: AppConstants.maxDisplayTime,
                                                     to: currentDate) ?? currentDate

            self.timeLapse = startRangeDate...endRangeDate
            self.timeLapseString = timeLapseString
            self.timerStatus = timerStatus
        }

        public init(timeLapse: ClosedRange<Date>, timeLapseString: String, timerStatus: TimerStatus) {

            self.timeLapse = timeLapse
            self.timeLapseString = timeLapseString
            self.timerStatus = timerStatus
        }

        /// 経過時間
        public var timeLapse: ClosedRange<Date>
        /// 経過時間の文字列
        public var timeLapseString: String
        /// タイマーの状態
        public var timerStatus: TimerStatus

        public var useableActions: [TimerActionType] {

            return timerStatus.useableActions
        }

        public var statusIcon: String {

            return timerStatus.icon
        }
    }

    public init() {}
}
#endif
