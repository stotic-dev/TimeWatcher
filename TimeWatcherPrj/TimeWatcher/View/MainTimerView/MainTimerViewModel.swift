//
//  MainTimerViewModel.swift
//  TimeWatcher
//
//  Created by 佐藤汰一 on 2024/09/11.
//

import SwiftUI

@MainActor
class MainTimerViewModel: ObservableObject {
    
    @Published var timerStatus: TimerStatus = .initial
    @Published var currentTimeString = "00:00:00.000"
    @Published var isOverMaxTime = false
    
    private var timeWatch: TimeWatch?
    
    // 最大表示時間
    private let maxDisplayTimeString = "99:59:59.999"
    // 表示最大可能時間
    private var maxDisplayTime: TimeInterval {
        
        let initialDate = Date(timeIntervalSince1970: .zero)
        return Calendar.current.date(byAdding: .hour,
                                     value: 100,
                                     to: initialDate)?.timeIntervalSince1970 ?? .infinity
    }
    
    init(timeWatch: TimeWatch? = nil, isOverMaxTime: Bool = false) {
        
        self.timeWatch = timeWatch
        self.isOverMaxTime = isOverMaxTime
        
        // テスト時以外はnilの状態なので、timeWatchの初期化を行う
        if self.timeWatch == nil {
            
            // TimeWatchオブジェクトの初期化
            logger.debug("timeWatch initial setting.")
            self.timeWatch = TimeWatch()
        }
        
        // 時間経過時に実行されるクロージャの設定
        self.timeWatch?.setTimerHandler { [weak self] timeLapse in
            
            guard let self else { return }
            self.didReceiveTimeLapse(timeLapse)
        }
    }
    
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

private extension MainTimerViewModel {
    
    /// タイマー開始ボタン押下
    func tappedStartTimerButton() {
        
        timerStatus = .start
        timeWatch?.startTimer()
    }
    
    /// タイマー停止ボタン押下
    func tappedStopTimerButton() {
        
        timerStatus = .stop
        timeWatch?.stopTimer()
    }
    
    /// タイマーリセットボタン押下
    func tappedResetTimerButton() {
        
        timerStatus = .initial
        timeWatch?.resetTimer()
    }
    
    // 時間経過検知時の処理
    func didReceiveTimeLapse(_ timeLapse: TimeInterval) {
        
        logger.debug("timeLapse: \(timeLapse)")
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
        logger.debug("hour: \(hour), minute: \(minute), sec: \(sec), millisec: \(millisec)")
        return String(format: "%02d:%02d:%02d.%03d", hour, minute, sec, millisec)
    }
}
