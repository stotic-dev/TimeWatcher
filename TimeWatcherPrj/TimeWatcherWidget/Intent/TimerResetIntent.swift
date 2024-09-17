//
//  TimerResetIntent.swift
//  TimeWatcherWidgetExtension
//
//  Created by 佐藤汰一 on 2024/09/17.
//

import AppIntents

struct TimerResetIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Reset"
    
    private var token: String?
    private(set) var timeWatch: TimeWatch
    private let liveActivityManager: LiveActivityManaging
    
    @MainActor
    init() {
        
        self.timeWatch = TimeWatch.shared
        self.liveActivityManager = LiveActivityManager()
    }
    
    @MainActor
    init(token: String,
         timeWatch: TimeWatch? = nil,
         liveActivityManager: LiveActivityManaging = LiveActivityManager()) {
        
        self.token = token
        self.timeWatch = timeWatch ?? TimeWatch.shared
        self.liveActivityManager = liveActivityManager
    }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        
        timeWatch.resetTimer()
        try await liveActivityManager.stop()
        return .result()
    }
}
