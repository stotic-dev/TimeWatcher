//
//  TestUtilities.swift
//  TimeWatcherTests
//
//  Created by 佐藤汰一 on 2024/09/17.
//

import Foundation
@testable import TimeWatcher

// MARK: - 便利メソッド

struct TestUtilities {
    
    static func getTimeLapse(base: Date, adding: [Calendar.Component: Int]) -> Date {
        
        return adding.reduce(into: base) {
            
            $0 = Calendar.current.date(byAdding: $1.key, value: $1.value, to: $0) ?? $0
        }
    }
    
    static func getAddingMilliSec(_ millisec: TimeInterval, to: Date) -> Date {
        
        let dateTime = to.timeIntervalSince1970MiliSec + millisec
        return Date(timeIntervalSince1970: dateTime / 1000)
    }
}
