//
//  TimerControlable.swift
//  TimeWatcherWidgetExtension
//
//  Created by 佐藤汰一 on 2024/09/17.
//

import Foundation

@MainActor
protocol TimerControlable: Sendable {
    
    var timeWatch: TimeWatch { get }
    var liveActivityManager: LiveActivityManaging { get }
    var dateDependency: DateDependency { get }
}

@MainActor
extension TimerControlable {
    
    func updateLiveActivity(status: TimerStatus) async throws {
        
        let timeLapse = timeWatch.getCurrentTimeLapse()
        try await liveActivityManager.update(state: .init(timeLapse: timeLapse,
                                                          currentDate: dateDependency.generateNow(),
                                                          timeLapseString: timeLapse.timeLapseShortString,
                                                          timerStatus: status))
    }
}
