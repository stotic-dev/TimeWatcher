//
//  TimerActionType.swift
//  TimeWatcher
//
//  Created by 佐藤汰一 on 2024/09/11.
//

/// タイマー操作のボタンの動作を定義
enum TimerActionType {
    
    /// 開始のアクション
    case start
    
    /// 停止のアクション
    case stop
    
    /// リセットのアクション
    case reset
}

// MARK: - 外部公開用のプロパティ定義
extension TimerActionType {
    
    var buttonTitle: String {
        
        switch self {
            
        case .start:
            "Start"
            
        case .stop:
            "Stop"
            
        case .reset:
            "Reset"
        }
    }
    
    var buttonIconName: String {
        
        switch self {
            
        case .start:
            "play.fill"
            
        case .stop:
            "pause.fill"
            
        case .reset:
            "xmark"
        }
    }
}
