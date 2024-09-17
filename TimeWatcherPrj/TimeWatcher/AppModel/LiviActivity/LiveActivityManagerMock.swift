//
//  LiveActivityManagerMock.swift
//  TimeWatcherTests
//
//  Created by 佐藤汰一 on 2024/09/15.
//

actor LiveActivityManagerMock: LiveActivityManaging {
    
    private var startProc: (TimeWatcherWidgetAttributes.ContentState) throws -> Void
    private var updateProc: (TimeWatcherWidgetAttributes.ContentState) throws -> Void
    private var stopProc: () throws -> Void
    
    init(startProc: @escaping (TimeWatcherWidgetAttributes.ContentState) throws -> Void,
         updateProc: @escaping (TimeWatcherWidgetAttributes.ContentState) throws -> Void,
         stopProc: @escaping () throws -> Void) {
        
        self.startProc = startProc
        self.updateProc = updateProc
        self.stopProc = stopProc
    }
    
    func start(attributes: TimeWatcherWidgetAttributes, state: TimeWatcherWidgetAttributes.ContentState) async throws {
        
        logger.debug("[In] state=\(state)")
        return try startProc(state)
    }
    
    func update(state: TimeWatcherWidgetAttributes.ContentState) async throws {
        
        logger.debug("[In] state=\(state)")
        try updateProc(state)
    }
    
    func stop() async throws {
        
        logger.debug("[In]")
        try stopProc()
    }
}
