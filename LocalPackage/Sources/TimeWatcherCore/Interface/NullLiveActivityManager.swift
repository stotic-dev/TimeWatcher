/// 何もしない LiveActivityManaging 実装（Preview・テストのデフォルト用）
public actor NullLiveActivityManager: LiveActivityManaging {

    public init() {}

    public func start(state: TimerLiveActivityState) async throws {}

    public func update(state: TimerLiveActivityState) async throws {}

    public func stop() async throws {}
}
