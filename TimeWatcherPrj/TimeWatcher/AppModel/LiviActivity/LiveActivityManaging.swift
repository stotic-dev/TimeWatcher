//
//  LiveActivityManaging.swift
//  TimeWatcher
//
//  Created by 佐藤汰一 on 2024/09/15.
//

protocol LiveActivityManaging {
    
    /// LiveActivityを開始する
    /// - Parameters:
    ///   - attributes: TimeWatcherWidgetAttributes
    ///   - state: LiveActivityに表示するコンテンツの情報
    /// - Returns: 開始したLiveActivityを操作するためのToken
    func start(attributes: TimeWatcherWidgetAttributes, state: TimeWatcherWidgetAttributes.ContentState) async throws -> String
    
    /// LiveActivityの情報の更新
    /// - Parameters:
    ///   - token: LiviActivity開始時に取得したToken
    ///   - state: 更新後のLiveActivityに表示するコンテンツの情報
    func update(token: String, state: TimeWatcherWidgetAttributes.ContentState) async throws
    
    /// LiveActivityの終了
    /// - Parameter token: LiviActivity開始時に取得したToken
    func stop(token: String) async throws
}
