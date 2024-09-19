//
//  TimerStopIntent.swift
//  TimeWatcherWidgetExtension
//
//  Created by 佐藤汰一 on 2024/09/17.
//

import AppIntents

struct TimerStopIntent: AppIntent, TimerControlable {
    
    static var title: LocalizedStringResource = "Stop"
    
    private(set) var timeWatch: TimeWatch
    private(set) var liveActivityManager: LiveActivityManaging
    private(set) var dateDependency: DateDependency
    
    @preconcurrency
    @MainActor
    init() {
        
        self.timeWatch = TimeWatch.shared
        self.liveActivityManager = LiveActivityManager()
        self.dateDependency = DateDependency()
    }
    
    @MainActor
    init(timeWatch: TimeWatch? = nil,
         liveActivityManager: LiveActivityManaging = LiveActivityManager(),
         dateDependency: DateDependency = DateDependency()) {
        
        self.timeWatch = timeWatch ?? TimeWatch.shared
        self.liveActivityManager = liveActivityManager
        self.dateDependency = dateDependency
    }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        
        try await updateLiveActivity(status: .stop)
        
        timeWatch.stopTimer()
        
        logger.info("Did stop timer.")
        return .result()
    }
}
