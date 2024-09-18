//
//  DateDependency.swift
//  TimeWatcher
//
//  Created by 佐藤汰一 on 2024/09/12.
//

import Foundation

final class DateDependency: @unchecked Sendable {
    
    var now: Date?
    private let isTest: Bool
    
    init(now: Date? = nil, isTest: Bool = false) {
        
        self.now = now
        self.isTest = isTest
    }
    
    func generateNow() -> Date {
        
        return isTest ? now ?? Date.now : Date.now
    }
}
