//
//  Calendar+Extension.swift
//  TimeWatcher
//
//  Created by 佐藤汰一 on 2024/09/14.
//

import Foundation

extension Calendar {
    
    func date(byAdding components: [Calendar.Component: Int], to: Date) -> Date {
        
        return components.reduce(into: to) {
            
            $0 = self.date(byAdding: $1.key, value: $1.value, to: $0) ?? $0
        }
    }
    
    func date(byAdding miliSec: Int, to: Date) -> Date {
        
        return Date(timeIntervalSince1970: (to.timeIntervalSince1970MiliSec + TimeInterval(miliSec)) / 1000)
    }
}
