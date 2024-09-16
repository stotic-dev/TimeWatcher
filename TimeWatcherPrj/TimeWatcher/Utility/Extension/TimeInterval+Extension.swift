//
//  TimeInterval+Extension.swift
//  TimeWatcher
//
//  Created by 佐藤汰一 on 2024/09/14.
//

import Foundation

extension TimeInterval {
    
    var hour: Int {
        
        return abs(Int(self / 3600))
    }
    
    var minute: Int {
        
        return Int(self / 60) % 60
    }
    
    var seconds: Int {
        
        return Int(self) % 60
    }
    
    var milliSec: Int {
        
        let timeLapse = self * 1000
        let roundTimeLapse = timeLapse.rounded()
        return Int(roundTimeLapse) % 1000
    }
}
