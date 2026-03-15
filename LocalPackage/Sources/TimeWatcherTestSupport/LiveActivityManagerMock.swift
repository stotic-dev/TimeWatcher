import TimeWatcherCore

public actor LiveActivityManagerMock: LiveActivityManaging {

    private var startProc: (TimerLiveActivityState) throws -> Void
    private var updateProc: (TimerLiveActivityState) throws -> Void
    private var stopProc: () throws -> Void

    public init(startProc: @escaping (TimerLiveActivityState) throws -> Void,
                updateProc: @escaping (TimerLiveActivityState) throws -> Void,
                stopProc: @escaping () throws -> Void) {

        self.startProc = startProc
        self.updateProc = updateProc
        self.stopProc = stopProc
    }

    public func start(state: TimerLiveActivityState) async throws {

        logger.debug("[In] state=\(state.timeLapseString)")
        try startProc(state)
    }

    public func update(state: TimerLiveActivityState) async throws {

        logger.debug("[In] state=\(state.timeLapseString)")
        try updateProc(state)
    }

    public func stop() async throws {

        logger.debug("[In]")
        try stopProc()
    }
}
