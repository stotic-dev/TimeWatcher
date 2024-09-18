//
//  AppConstants.swift
//  TimeWatcher
//
//  Created by 佐藤汰一 on 2024/09/17.
//

import Foundation

struct AppConstants {
    
    // MARK: - アプリ共通
    
    static let mainBundleId = "taichi.satou.TimeWatcher"
    
    // MARK: - ウォッチ関連のプロパティ
    
    // 最大表示時間
    static let maxDisplayTimeString = "99:59:59.999"
    // 最大表示時間
    static let maxDisplayShortTimeString = "99:59:59"
    // 表示最大可能経過時間
    static var maxDisplayTime = 100
    // 表示最大可能経過時間
    static var maxDisplayTimeLapse: TimeInterval = 360000
}
