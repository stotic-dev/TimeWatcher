//
//  TimerStartIntent.swift
//  TimeWatcherWidgetExtension
//
//  Created by 佐藤汰一 on 2024/09/17.
//

import AppIntents

struct TimerStartIntent: LiveActivityIntent, TimerControlable {
    
    static var title: LocalizedStringResource = "Start"
    
    private(set) var liveActivityManager: LiveActivityManaging
    private(set) var timeWatch: TimeWatch
    private(set) var dateDependency: DateDependency
    
    @preconcurrency
    @MainActor
    init() {
        
        liveActivityManager = LiveActivityManager()
        timeWatch = TimeWatch.shared
        dateDependency = DateDependency()
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
        
        try await updateLiveActivity(status: .start)
        timeWatch.startTimer()
        
        logger.info("Did start timer.")
        return .result()
    }
}
