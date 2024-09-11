//
//  MainTimerViewModel.swift
//  TimeWatcher
//
//  Created by 佐藤汰一 on 2024/09/11.
//

import SwiftUI

class MainTimerViewModel: ObservableObject {
    
    @Published var timerStatus: TimerStatus = .initial
    
    /// タイマーのアクションボタン投下時の動作を、アクションタイプから決定して実行する
    /// - Parameter type: アクションタイプ
    func tappedTimerActionButton(_ type: TimerActionType) {
        
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

private extension MainTimerViewModel {
    
    /// タイマー開始ボタン押下
    func tappedStartTimerButton() {
        
        timerStatus = .start
    }
    
    /// タイマー停止ボタン押下
    func tappedStopTimerButton() {
        
        timerStatus = .stop
    }
    
    /// タイマーリセットボタン押下
    func tappedResetTimerButton() {
        
        timerStatus = .initial
    }
}
