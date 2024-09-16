//
//  LiveActivityManagerMock.swift
//  TimeWatcherTests
//
//  Created by 佐藤汰一 on 2024/09/15.
//

actor LiveActivityManagerMock: LiveActivityManaging {
    
    private var startProc: (TimeWatcherWidgetAttributes.ContentState) throws -> String
    private var updateProc: (String, TimeWatcherWidgetAttributes.ContentState) throws -> Void
    private var stopProc: (String) throws -> Void
    
    init(startProc: @escaping (TimeWatcherWidgetAttributes.ContentState) throws -> String,
         updateProc: @escaping (String, TimeWatcherWidgetAttributes.ContentState) throws -> Void,
         stopProc: @escaping (String) throws -> Void) {
        
        self.startProc = startProc
        self.updateProc = updateProc
        self.stopProc = stopProc
    }
    
    func start(attributes: TimeWatcherWidgetAttributes, state: TimeWatcherWidgetAttributes.ContentState) async throws -> String {
        
        logger.debug("[In] state=\(state)")
        return try startProc(state)
    }
    
    func update(token: String, state: TimeWatcherWidgetAttributes.ContentState) async throws {
        
        logger.debug("[In] token=\(token), state=\(state)")
        try updateProc(token, state)
    }
    
    func stop(token: String) async throws {
        
        logger.debug("[In] token=\(token)")
        try stopProc(token)
    }
}
