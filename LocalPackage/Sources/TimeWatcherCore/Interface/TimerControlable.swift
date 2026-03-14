import Foundation

/// Widget Intent がタイマーを操作するためのプロトコル
@MainActor
public protocol TimerControlable: Sendable {

    var timeWatch: TimeWatch { get }
    var liveActivityManager: LiveActivityManaging { get }
    var dateDependency: DateDependency { get }
}

@MainActor
extension TimerControlable {

    public func updateLiveActivity(status: TimerStatus) async throws {

        let timeLapse = timeWatch.getCurrentTimeLapse()
        try await liveActivityManager.update(state: TimerLiveActivityState(
            timeLapse: timeLapse,
            currentDate: dateDependency.generateNow(),
            timeLapseString: timeLapse.timeLapseShortString,
            timerStatus: status
        ))
    }
}
