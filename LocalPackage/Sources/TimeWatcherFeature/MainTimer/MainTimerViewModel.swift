import Combine
import SwiftUI
import TimeWatcherCore

@MainActor
public class MainTimerViewModel: ObservableObject {

    // MARK: observe target property

    @Published public var timerStatus: TimerStatus = .initial
    @Published public var currentTimeString = "00:00:00.000"
    @Published public var isOverMaxTime = false

    // 1分基準の経過時間の進捗
    public var timeProgressPerMinute: Double {

        return currentTimeLapse / 10
    }

    // MARK: dependency property

    private var timeWatch: TimeWatch
    private let liveActivityMgr: LiveActivityManaging
    private let dateDependency: DateDependency

    // MARK: private property

    // LiveActivityが開始しているかどうか
    private var isStartingLiveActivity = false
    // 現在の経過時間
    private var currentTimeLapse: TimeInterval = .zero
    // Live Activityの更新リクエストTask
    private var updateLiveActivityRequestTasks = Set<Task<Void, Never>>()
    // タイマー状態監視用のキャンセラブル
    private var timerStatusObserveCancellable: AnyCancellable?

    // 表示最大可能時間
    private var maxDisplayTime: TimeInterval {

        let initialDate = Date(timeIntervalSince1970: .zero)
        return Calendar.current.date(byAdding: .hour,
                                     value: AppConstants.maxDisplayTime,
                                     to: initialDate)?.timeIntervalSince1970 ?? .infinity
    }

    public init(timeWatch: TimeWatch? = nil,
                liveActivityMgr: LiveActivityManaging = NullLiveActivityManager(),
                dateDependency: DateDependency = DateDependency(),
                isOverMaxTime: Bool = false) {

        self.timeWatch = timeWatch ?? TimeWatch.shared
        self.liveActivityMgr = liveActivityMgr
        self.dateDependency = dateDependency
        self.isOverMaxTime = isOverMaxTime

        // 時間経過時に実行されるクロージャの設定
        self.timeWatch.setTimerHandler { @MainActor [weak self] timeLapse in

            guard let self else { return }
            self.didReceiveTimeLapse(timeLapse)
        }
    }

    // MARK: - public method

    /// 画面表示時の処理
    public func onAppear() {

        logger.info("[In]")

        // TimerStatusの監視
        addObserveTimerStatus()
    }

    /// タイマーのアクションボタン投下時の動作を、アクションタイプから決定して実行する
    public func tappedTimerActionButton(_ type: TimerActionType) {

        logger.info("type=\(type)")

        switch type {

        case .start:
            startTimer()

        case .stop:
            stopTimer()

        case .reset:
            resetTimer()
        }
    }

    /// LiveActivityのDeepLinkでアプリが開かれたことを検知
    public func onOpenLiveActivityUrl(_ url: WidgetUrlKey) {

        logger.info("url: \(url)")

        if url != .timerResetLink { return }

        resetTimer()
    }
}

// MARK: - private method

@MainActor
private extension MainTimerViewModel {

    func addObserveTimerStatus() {

        logger.info("[In]")

        timerStatusObserveCancellable = timeWatch.createTimerStatusPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in

                guard let self else { return }
                self.timerStatus = status

                logger.info("Did update timer status(\(status))")
            }
    }

    func startTimer() {

        logger.info("[In]")

        timeWatch.startTimer()

        if isStartingLiveActivity { return }

        Task {

            do {

                try await liveActivityMgr.start(state: getCurrentLiveActivityState(timeLapse: currentTimeLapse,
                                                                                   timerStatus: .start))
                isStartingLiveActivity = true
                logger.info("Succeed start live activity.")
            }
            catch {

                catchLiveActivityRequestError(error, from: "start")
            }
        }
    }

    func stopTimer() {

        logger.info("[In]")

        cancelLiveActivityTask()

        timeWatch.stopTimer()

        guard isStartingLiveActivity else {

            logger.error("Live Activity is not running.")
            return
        }

        Task { [currentTimeLapse] in

            await self.requestUpdateLiveActivityState(timeLapse: currentTimeLapse,
                                                      timerStatus: .stop)
            logger.info("Succeed update stop liviActivity.")
        }
    }

    func resetTimer() {

        logger.info("[In]")

        cancelLiveActivityTask()

        timeWatch.resetTimer()

        guard isStartingLiveActivity else {

            logger.error("Live Activity is not running.")
            return
        }

        isStartingLiveActivity = false

        Task {

            do {

                try await liveActivityMgr.stop()
                logger.info("Succeed end liviActivity.")
            }
            catch {

                catchLiveActivityRequestError(error, from: "end")
            }
        }
    }

    func didReceiveTimeLapse(_ timeLapse: TimeInterval) {

        if timeLapse.seconds > self.currentTimeLapse.seconds,
           isStartingLiveActivity {

            let task = Task { [timerStatus] in

                guard timerStatus == .start,
                      let targetTask = self.updateLiveActivityRequestTasks.popFirst() else {

                    logger.debug("current state is not start(\(timerStatus)).")
                    return
                }

                await self.requestUpdateLiveActivityState(timeLapse: timeLapse,
                                                          timerStatus: timerStatus)

                targetTask.cancel()
                logger.debug("Did update on received time lapse(status=\(timerStatus)).")
            }
            updateLiveActivityRequestTasks.insert(task)
        }

        self.currentTimeLapse = timeLapse
        self.currentTimeString = timeLapse.timeLapseFullString
        self.isOverMaxTime = self.currentTimeString == AppConstants.maxDisplayTimeString
    }

    func cancelLiveActivityTask() {

        let taskCount = updateLiveActivityRequestTasks.count

        updateLiveActivityRequestTasks.forEach { $0.cancel() }
        updateLiveActivityRequestTasks.removeAll()

        logger.info("Did cancel all activity task(count=\(taskCount)).")
    }

    func requestUpdateLiveActivityState(timeLapse: TimeInterval,
                                        timerStatus: TimerStatus) async {

        do {

            try await self.liveActivityMgr.update(state: getCurrentLiveActivityState(timeLapse: timeLapse,
                                                                                     timerStatus: timerStatus))
        }
        catch {

            catchLiveActivityRequestError(error, from: "update")
        }
    }

    func getCurrentLiveActivityState(timeLapse: TimeInterval, timerStatus: TimerStatus) -> TimerLiveActivityState {

        logger.debug("state info(timeLapse=\(timeLapse.timeLapseShortString), status=\(timerStatus))")

        return TimerLiveActivityState(
            timeLapse: timeLapse,
            currentDate: dateDependency.generateNow(),
            timeLapseString: timeLapse.timeLapseShortString,
            timerStatus: timerStatus
        )
    }

    func catchLiveActivityRequestError(_ error: Error, from: String) {

        logger.error("Failed live activity \(from) request(\(error)).")
    }
}
