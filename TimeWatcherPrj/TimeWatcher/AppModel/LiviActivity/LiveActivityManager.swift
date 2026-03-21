//
//  LiveActivityManager.swift
//  TimeWatcher
//
//  Created by 佐藤汰一 on 2024/09/14.
//

import ActivityKit
import Foundation
import TimeWatcherCore
import TimeWatcherFeature

actor LiveActivityManager: LiveActivityManaging {

    private static let terminateTimeout: TimeInterval = 3

    func start(state: TimerLiveActivityState) async throws {

        let widgetState = TimeWatcherWidgetAttributes.ContentState(
            timeLapse: state.timeLapse,
            currentDate: state.currentDate,
            timeLapseString: state.timeLapseString,
            timerStatus: state.timerStatus
        )
        let activity = try Activity<TimeWatcherWidgetAttributes>.request(
            attributes: .init(),
            content: .init(state: widgetState, staleDate: nil)
        )
        TimeWatchLiveActivitiesStore.shared.setActivity(activity)
    }

    func update(state: TimerLiveActivityState) async throws {

        guard let activity = TimeWatchLiveActivitiesStore.shared.activity else {

            throw LiveActivityRequestError.notFoundActivity
        }

        let widgetState = TimeWatcherWidgetAttributes.ContentState(
            timeLapse: state.timeLapse,
            currentDate: state.currentDate,
            timeLapseString: state.timeLapseString,
            timerStatus: state.timerStatus
        )
        await activity.update(.init(state: widgetState, staleDate: nil))
    }

    func stop() async throws {

        guard let activity = TimeWatchLiveActivitiesStore.shared.activity else {

            throw LiveActivityRequestError.notFoundActivity
        }

        TimeWatchLiveActivitiesStore.shared.clear()

        await activity.end(.init(state: activity.content.state, staleDate: nil),
                           dismissalPolicy: .immediate)
    }

    /// 起動しているLiveActivityの終了
    nonisolated func terminate() {

        let semaphore = DispatchSemaphore(value: 0)

        Task {

            for activity in Activity<TimeWatcherWidgetAttributes>.activities {

                await activity.end(nil, dismissalPolicy: .immediate)
            }

            semaphore.signal()
        }

        let result = semaphore.wait(timeout: .now() + Self.terminateTimeout)
        logger.info("result: \(result)")
    }
}

class TimeWatchLiveActivitiesStore {

    static var shared = TimeWatchLiveActivitiesStore()

    private(set) var activity: Activity<TimeWatcherWidgetAttributes>?

    fileprivate func setActivity(_ activity: Activity<TimeWatcherWidgetAttributes>) {

        self.activity = activity
    }

    fileprivate func clear() {

        self.activity = nil
    }
}
