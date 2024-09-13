//
//  Date+Extension.swift
//  TimeWatcher
//
//  Created by 佐藤汰一 on 2024/09/11.
//

import Foundation

extension Date {
    
    var timeIntervalSince1970MiliSec: TimeInterval {
        
        return self.timeIntervalSince1970 * 1000
    }
    
    func toStringDate() -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS"
        return formatter.string(from: self)
    }
}
