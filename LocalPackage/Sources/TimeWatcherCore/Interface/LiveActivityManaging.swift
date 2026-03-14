/// LiveActivityを管理するプロトコル（ActivityKit非依存）
public protocol LiveActivityManaging: Sendable {

    /// LiveActivityを開始する
    func start(state: TimerLiveActivityState) async throws

    /// LiveActivityの情報の更新
    func update(state: TimerLiveActivityState) async throws

    /// LiveActivityの終了
    func stop() async throws
}

/// LiveActivity操作時のエラー
public enum LiveActivityRequestError: Error, Equatable {

    case notFoundActivity
}
