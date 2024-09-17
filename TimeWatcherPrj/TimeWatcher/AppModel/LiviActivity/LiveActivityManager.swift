//
//  LiveActivityManager.swift
//  TimeWatcher
//
//  Created by 佐藤汰一 on 2024/09/14.
//

import ActivityKit

actor LiveActivityManager: LiveActivityManaging {
    
    func start(attributes: TimeWatcherWidgetAttributes, state: TimeWatcherWidgetAttributes.ContentState) async throws {
        
        let activity = try Activity<TimeWatcherWidgetAttributes>.request(attributes: attributes,
                                                                         content: .init(state: state,
                                                                                        staleDate: nil))
        TimeWatchLiveActivitiesStore.shared.setActivity(activity)
    }
    
    func update(state: TimeWatcherWidgetAttributes.ContentState) async throws {
        
        guard let activity = TimeWatchLiveActivitiesStore.shared.activity else {
            
            throw LiveActivityRequestError.notFoundActivity
        }
        
        await activity.update(.init(state: state, staleDate: nil))
    }
    
    func stop() async throws {
        
        guard let activity = TimeWatchLiveActivitiesStore.shared.activity else {
            
            throw LiveActivityRequestError.notFoundActivity
        }
        
        TimeWatchLiveActivitiesStore.shared.clear()
        
        await activity.end(.init(state: activity.content.state, staleDate: nil),
                           dismissalPolicy: .immediate)
    }
}

enum LiveActivityRequestError: Error {
    
    case notFoundActivity
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
