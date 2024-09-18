//
//  MainTimerViewModel.swift
//  TimeWatcher
//
//  Created by 佐藤汰一 on 2024/09/11.
//

import Combine
import SwiftUI
import ActivityKit

@MainActor
class MainTimerViewModel: ObservableObject {
    
    // MARK: observe target property
    
    @Published var timerStatus: TimerStatus = .initial
    @Published var currentTimeString = "00:00:00.000"
    @Published var isOverMaxTime = false
    
    // 1分基準の経過時間の進捗
    var timeProgressPerMinute: Double {
        
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
    
    init(timeWatch: TimeWatch? = nil,
         liveActivityMgr: LiveActivityManaging = LiveActivityManager(),
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
    func onAppear() {
        
        logger.info("[In]")
        
        // TimerStatusの監視
        addObserveTimerStatus()
    }
    
    /// タイマーのアクションボタン投下時の動作を、アクションタイプから決定して実行する
    /// - Parameter type: アクションタイプ
    func tappedTimerActionButton(_ type: TimerActionType) {
        
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
    /// - Parameter url: LiveActivityから開かれるURLのKey
    func onOpenLiveActivityUrl(_ url: WidgetUrlKey) {
        
        logger.info("url: \(url)")
        
        // リセット以外のリンクの場合は、特に実行する処理はないため無視する
        if url != .timerResetLink { return }
        
        // タイマーをリセットする
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
    
    /// タイマー開始
    func startTimer() {
        
        logger.info("[In]")
        
        timeWatch.startTimer()
        
        // Live Activityが開始されていない場合は、新規にLive Activityを開始する
        if isStartingLiveActivity { return }
        
        Task {
            
            do {
                
                try await liveActivityMgr
                    .start(attributes: .init(),
                           state: getCurrentLiveActivityState(timeLapse: currentTimeLapse,
                                                              timerStatus: .start))
                isStartingLiveActivity = true
                logger.info("Succeed start live activity.")
            }
            catch {
                
                catchLiveActivityRequestError(error, from: "start")
            }
        }
    }
    
    /// タイマー停止
    func stopTimer() {
        
        logger.info("[In]")
        
        // 現在リクエストしているTaskをすべてキャンセルする
        cancelLiveActivityTask()
        
        // タイマー停止
        timeWatch.stopTimer()
        
        // LiveActivityが開始していない場合は、停止時の更新も行わない
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
    
    /// タイマーリセット
    func resetTimer() {
        
        logger.info("[In]")
        
        // 現在リクエストしているTaskをすべてキャンセルする
        cancelLiveActivityTask()
        
        // タイマー終了(リセット)
        timeWatch.resetTimer()
        
        // LiveActivityが開始していない場合は、停止時の更新も行わない
        guard isStartingLiveActivity else {
            
            logger.error("Live Activity is not running.")
            return
        }
        
        // Model上でLiveActivityの動作を停止する
        isStartingLiveActivity = false
        
        // Live Activityの停止
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
    
    // 時間経過検知時の処理
    func didReceiveTimeLapse(_ timeLapse: TimeInterval) {
        
        // s単位の更新がある場合に、LiveActivityの更新を行う
        // ms単位の更新を行うと、非同期のタスクが逼迫しパフォーマンスやデータレースの懸念があるため
        // LiveActivityが開始されていない場合にも、LiveActivityの更新は行わない
        if timeLapse.seconds > self.currentTimeLapse.seconds,
           isStartingLiveActivity {
            
            let task = Task { [timerStatus] in
                
                // タイマー開始状態でない場合は時間経過の検知は無視する
                guard timerStatus == .start,
                      let targetTask = self.updateLiveActivityRequestTasks.popFirst() else {
                    
                    logger.debug("current state is not start(\(timerStatus)).")
                    return
                }
                
                await self.requestUpdateLiveActivityState(timeLapse: timeLapse,
                                                          timerStatus: timerStatus)
                
                // タスクの終了
                targetTask.cancel()
                logger.debug("Did update on received time lapse(status=\(timerStatus)).")
            }
            updateLiveActivityRequestTasks.insert(task)
        }
        
        // 現在の経過時間の更新
        self.currentTimeLapse = timeLapse
        self.currentTimeString = timeLapse.timeLapseFullString
        self.isOverMaxTime = self.currentTimeString == AppConstants.maxDisplayTimeString
    }
    
    // LiveActivityの更新タスクをすべてキャンセルする
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
    
    // 現在のタイマーの状態をLiveActivityで受け取れる型として返却
    func getCurrentLiveActivityState(timeLapse: TimeInterval, timerStatus: TimerStatus) -> TimeWatcherWidgetAttributes.ContentState {
        
        logger.debug("state info(timeLapse=\(timeLapse.timeLapseShortString), status=\(timerStatus))")
        
        return .init(timeLapse: timeLapse,
                     currentDate: dateDependency.generateNow(),
                     timeLapseString: timeLapse.timeLapseShortString,
                     timerStatus: timerStatus)
    }
    
    func catchLiveActivityRequestError(_ error: Error, from: String) {
        
        if let error = error as? ActivityAuthorizationError {
            
            logger.error("catch ActivityAuthorizationError(reason=\(String(describing: error.failureReason)), suggestion=\(String(describing: error.recoverySuggestion))).")
        }
        
        logger.error("Failed live activity \(from) request(\(error)).")
    }
}
