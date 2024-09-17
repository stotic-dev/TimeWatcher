//
//  LiveActivityManaging.swift
//  TimeWatcher
//
//  Created by 佐藤汰一 on 2024/09/15.
//

protocol LiveActivityManaging: Sendable {
    
    /// LiveActivityを開始する
    /// - Parameters:
    ///   - attributes: TimeWatcherWidgetAttributes
    ///   - state: LiveActivityに表示するコンテンツの情報
    func start(attributes: TimeWatcherWidgetAttributes, state: TimeWatcherWidgetAttributes.ContentState) async throws
    
    /// LiveActivityの情報の更新
    /// - Parameters:
    ///   - state: 更新後のLiveActivityに表示するコンテンツの情報
    func update(state: TimeWatcherWidgetAttributes.ContentState) async throws
    
    /// LiveActivityの終了
    func stop() async throws
}
