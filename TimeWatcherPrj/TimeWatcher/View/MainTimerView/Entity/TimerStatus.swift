//
//  TimerStatus.swift
//  TimeWatcher
//
//  Created by 佐藤汰一 on 2024/09/11.
//

/// タイマーの動作状態
enum TimerStatus: Codable {
    
    /// 停止中(タイマーリセット済み)
    case initial
    /// 停止中(タイマーリセット前)
    case stop
    /// 開始中
    case start
}

// MARK: - 外部公開用のプロパティ
extension TimerStatus {
    
    /// 使用可能なタイマーアクション
    var useableActions: [TimerActionType] {
        
        return switch self {
        
        case .initial:
             [.start]
            
        case .stop:
            [.reset, .start]
            
        case .start:
            [.reset, .stop]
        }
    }
    
    /// 経過時間計測中かどうか
    var isPlaying: Bool {
        
        return switch self {
            
        case .initial, .stop:
            false
            
        case .start:
            true
        }
    }
}
