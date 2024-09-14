//
//  DateDependency.swift
//  TimeWatcher
//
//  Created by 佐藤汰一 on 2024/09/12.
//

import Foundation

class DateDependency {
    
    var now: Date?
    
    init(now: Date? = nil) {
        
        self.now = now
    }
    
    func generateNow() -> Date {
        
        return now ?? Date.now
    }
}
