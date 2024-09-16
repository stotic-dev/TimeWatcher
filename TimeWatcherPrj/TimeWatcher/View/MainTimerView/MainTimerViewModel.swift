//
//  MainTimerViewModel.swift
//  TimeWatcher
//
//  Created by 佐藤汰一 on 2024/09/11.
//

import SwiftUI
import ActivityKit

@MainActor
class MainTimerViewModel: ObservableObject {
    
    // MARK: observe target property
    
    @Published var timerStatus: TimerStatus = .initial
    @Published var currentTimeString = "00:00:00.000"
    @Published var isOverMaxTime = false
    
    // MARK: dependency property
    
    private var timeWatch: TimeWatch?
    private let liveActivityMgr: LiveActivityManaging
    private let dateDependency: DateDependency
    
    // MARK: private property
    
    // 実行中のLiveActivityのToken
    private var currentLiveActivityToken: String?
    // 現在の経過時間
    private var currentTimeLapse: TimeInterval = .zero
    // Live Activityの更新リクエストTask
    private var updateLiveActivityRequestTasks = Set<Task<Void, Never>>()
    
    // 1分基準の経過時間の進捗
    private var timeProgressPerMinute: Double {
        
        return currentTimeLapse / 60
    }
    
    // 最大表示時間
    private let maxDisplayTimeString = "99:59:59.999"
    // 表示最大可能時間
    private var maxDisplayTime: TimeInterval {
        
        let initialDate = Date(timeIntervalSince1970: .zero)
        return Calendar.current.date(byAdding: .hour,
                                     value: 100,
                                     to: initialDate)?.timeIntervalSince1970 ?? .infinity
    }
    
    init(timeWatch: TimeWatch? = nil,
         liveActivityMgr: LiveActivityManaging = LiveActivityManager(),
         dateDependency: DateDependency = DateDependency(),
         isOverMaxTime: Bool = false) {
        
        self.timeWatch = timeWatch
        self.liveActivityMgr = liveActivityMgr
        self.dateDependency = dateDependency
        self.isOverMaxTime = isOverMaxTime
        
        // テスト時以外はnilの状態なので、timeWatchの初期化を行う
        if self.timeWatch == nil {
            
            // TimeWatchオブジェクトの初期化
            logger.debug("timeWatch initial setting.")
            self.timeWatch = TimeWatch()
        }
        
        // 時間経過時に実行されるクロージャの設定
        self.timeWatch?.setTimerHandler { @MainActor [weak self] timeLapse in
            
            guard let self else { return }
            self.didReceiveTimeLapse(timeLapse)
        }
    }
    
    // MARK: - public method
    
    /// タイマーのアクションボタン投下時の動作を、アクションタイプから決定して実行する
    /// - Parameter type: アクションタイプ
    func tappedTimerActionButton(_ type: TimerActionType) {
        
        logger.info("type=\(type)")
        
        switch type {
            
        case .start:
            tappedStartTimerButton()
            
        case .stop:
            tappedStopTimerButton()
            
        case .reset:
            tappedResetTimerButton()
        }
    }
}

// MARK: - private method

@MainActor
private extension MainTimerViewModel {
    
    /// タイマー開始ボタン押下
    func tappedStartTimerButton() {
        
        timerStatus = .start
        timeWatch?.startTimer()
        
        // Live Activityが開始されていない場合は、新規にLive Activityを開始する
        if currentLiveActivityToken == nil {
            
            Task {
                
                do {
                    
                    currentLiveActivityToken = try await liveActivityMgr
                        .start(attributes: .init(),
                               state: getCurrentLiveActivityState(timeLapse: currentTimeLapse,
                                                                  timerStatus: timerStatus))
                    logger.info("Succeed start live activity(token=\(String(describing: currentLiveActivityToken)))")
                }
                catch {
                    
                    catchLiveActivityRequestError(error, from: "start")
                }
            }
        }
    }
    
    /// タイマー停止ボタン押下
    func tappedStopTimerButton() {
        
        // 現在リクエストしているTaskをすべてキャンセルする
        cancelLiveActivityTask()
        
        timerStatus = .stop
        timeWatch?.stopTimer()
        
        // LiveActivityTokenがない場合は、開始できていないため停止時の更新も行わない
        guard let currentLiveActivityToken else {
            
            logger.error("Not found currentLiveActivityToken.")
            return
        }
        
        Task { [currentLiveActivityToken, currentTimeLapse, timerStatus] in
            
            await self.requestUpdateLiveActivityState(currentLiveActivityToken: currentLiveActivityToken,
                                                      timeLapse: currentTimeLapse,
                                                      timerStatus: timerStatus)
            logger.info("Succeed update stop liviActivity(\(currentLiveActivityToken)).")
        }
    }
    
    /// タイマーリセットボタン押下
    func tappedResetTimerButton() {
        
        // 現在リクエストしているTaskをすべてキャンセルする
        cancelLiveActivityTask()
        
        timerStatus = .initial
        timeWatch?.resetTimer()
        
        // LiveActivityTokenがない場合は、開始できていないため停止のリクエストも行わない
        guard let currentLiveActivityToken else {
            
            logger.error("Not found currentLiveActivityToken.")
            return
        }
        
        // Live Activityの停止
        Task {
            
            do {
                
                try await liveActivityMgr.stop(token: currentLiveActivityToken)
                logger.info("Succeed end liviActivity(\(currentLiveActivityToken)).")
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
        if timeLapse.seconds > self.currentTimeLapse.seconds,
           let currentLiveActivityToken {
            
            let task = Task { [currentLiveActivityToken, timerStatus] in
                
                // タイマー開始状態でない場合は時間経過の検知は無視する
                guard timerStatus == .start,
                      let targetTask = self.updateLiveActivityRequestTasks.popFirst() else {
                    
                    logger.debug("current state is not start(\(timerStatus)).")
                    return
                }
                
                await self.requestUpdateLiveActivityState(currentLiveActivityToken: currentLiveActivityToken,
                                                          timeLapse: timeLapse,
                                                          timerStatus: timerStatus)
                
                // タスクの終了
                targetTask.cancel()
                logger.debug("Did update on received time lapse(token=\(currentLiveActivityToken), status=\(timerStatus)).")
            }
            updateLiveActivityRequestTasks.insert(task)
        }
        
        // 現在の経過時間の更新
        self.currentTimeLapse = timeLapse
        self.currentTimeString = self.getTimeString(timeLapse)
        self.isOverMaxTime = self.currentTimeString == maxDisplayTimeString
    }
    
    // タイムスタンプ(sec)から画面に表示する表示文字列を返す
    func getTimeString(_ timeLapse: TimeInterval) -> String {
        
        guard maxDisplayTime > timeLapse else {
            
            return maxDisplayTimeString
        }
        
        let millisec = Int(round(timeLapse * 1000)) % 1000
        let sec = Int(timeLapse) % 60
        let minute = Int(timeLapse / 60) % 60
        let hour = abs(Int(timeLapse / 3600))
        return String(format: "%02d:%02d:%02d.%03d", hour, minute, sec, millisec)
    }
    
    // LiveActivityの更新タスクをすべてキャンセルする
    func cancelLiveActivityTask() {
        
        let taskCount = updateLiveActivityRequestTasks.count
        
        updateLiveActivityRequestTasks.forEach { $0.cancel() }
        updateLiveActivityRequestTasks.removeAll()
        
        logger.info("Did cancel all activity task(count=\(taskCount)).")
    }
    
    func requestUpdateLiveActivityState(currentLiveActivityToken: String,
                                        timeLapse: TimeInterval,
                                        timerStatus: TimerStatus) async {
        
        do {
            
            try await self.liveActivityMgr.update(token: currentLiveActivityToken,
                                                  state: getCurrentLiveActivityState(timeLapse: timeLapse,
                                                                                     timerStatus: timerStatus))
        }
        catch {
            
            catchLiveActivityRequestError(error, from: "update")
        }
    }
    
    // 現在のタイマーの状態をLiveActivityで受け取れる型として返却
    func getCurrentLiveActivityState(timeLapse: TimeInterval, timerStatus: TimerStatus) -> TimeWatcherWidgetAttributes.ContentState {
        
        let addingMilliSecDate = Calendar.current.date(byAdding: -timeLapse.milliSec, to: dateDependency.generateNow())
        let closedRangeStartDate = Calendar.current.date(byAdding: [
            .hour: -timeLapse.hour,
            .minute: -timeLapse.minute,
            .second: -timeLapse.seconds
        ],
                                               to: addingMilliSecDate)
        let closedRangeEndDate = Calendar.current.date(byAdding: .hour,
                                                       value: 100,
                                                       to: dateDependency.generateNow())
        
        logger.debug("state info(timeLapse=\(String(currentTimeString.prefix(8))), status=\(timerStatus), closedRangeStartDate=\(closedRangeStartDate.toStringDate()), closedRangeEndDate=\(String(describing: closedRangeEndDate?.toStringDate())))")
        
        return .init(timeLapse: closedRangeStartDate...(closedRangeEndDate ?? dateDependency.generateNow()),
                     timeLapseString: String(currentTimeString.prefix(8)),
                     timerStatus: timerStatus)
    }
    
    func catchLiveActivityRequestError(_ error: Error, from: String) {
        
        if let error = error as? ActivityAuthorizationError {
            
            logger.error("catch ActivityAuthorizationError(reason=\(String(describing: error.failureReason)), suggestion=\(String(describing: error.recoverySuggestion))).")
        }
        
        logger.error("Failed live activity \(from) request(\(error)).")
    }
}
