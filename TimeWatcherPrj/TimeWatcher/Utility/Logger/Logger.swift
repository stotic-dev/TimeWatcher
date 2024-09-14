//
//  Logger.swift
//  TimeWatcher
//
//  Created by 佐藤汰一 on 2024/09/11.
//

import Foundation
import OSLog

let logger = CustomLogger()

struct CustomLogger {
    
    #if DEBUG
    private let logger = Logger(subsystem: "taichi.satou.TimeWatcher", category: "DEBUG CONFIG")
    #else
    private let logger = Logger(subsystem: "taichi.satou.TimeWatcher", category: "PRD CONFIG")
    #endif
    
    func debug(_ message: String, file: String = #fileID, function: String = #function, line: Int = #line) {
        
        logger.debug("🟩 [DEBUG] [\(file):\(function) \(line)]: \(message)")
    }
    
    func info(_ message: String, file: String = #fileID, function: String = #function, line: Int = #line) {
        
        logger.info("🟪 [INFO] [\(file):\(function) \(line)]: \(message)")
    }
    
    func warning(_ message: String, file: String = #fileID, function: String = #function, line: Int = #line) {
        
        logger.warning("🟨 [WARNING] [\(file):\(function) \(line)]: \(message)")
    }
    
    func error(_ message: String, file: String = #fileID, function: String = #function, line: Int = #line) {
        
        logger.error("🟥 [ERROR] [\(file):\(function) \(line)]: \(message)")
    }
}
