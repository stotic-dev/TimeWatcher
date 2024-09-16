//
//  LiveActivityManager.swift
//  TimeWatcher
//
//  Created by 佐藤汰一 on 2024/09/14.
//

import ActivityKit

actor LiveActivityManager: LiveActivityManaging {
    
    func start(attributes: TimeWatcherWidgetAttributes, state: TimeWatcherWidgetAttributes.ContentState) async throws -> String {
        
        let activity = try Activity<TimeWatcherWidgetAttributes>.request(attributes: attributes,
                                                                         content: .init(state: state,
                                                                                        staleDate: nil))
        LiveActivitiesStore.shared[activity.id] = activity
        return activity.id
    }
    
    func update(token: String, state: TimeWatcherWidgetAttributes.ContentState) async throws {
        
        guard let activity = LiveActivitiesStore.shared[token] else {
            
            throw LiveActivityRequestError.notFoundActivity
        }
        
        await activity.update(.init(state: state, staleDate: nil))
    }
    
    func stop(token: String) async throws {
        
        guard let activity = LiveActivitiesStore.shared[token] else {
            
            throw LiveActivityRequestError.notFoundActivity
        }
        
        LiveActivitiesStore.shared[token] = nil
        
        await activity.end(.init(state: activity.content.state, staleDate: nil),
                           dismissalPolicy: .immediate)
    }
}

enum LiveActivityRequestError: Error {
    
    case notFoundActivity
}

class LiveActivitiesStore {
    
    static var shared = LiveActivitiesStore()
    
    private var store: [String: Activity<TimeWatcherWidgetAttributes>] = [:]
    
    subscript(_ id: String) -> Activity<TimeWatcherWidgetAttributes>? {
        
        get {
            
            return store[id]
        }
        
        set {
            
            store[id] = newValue
        }
    }
}
