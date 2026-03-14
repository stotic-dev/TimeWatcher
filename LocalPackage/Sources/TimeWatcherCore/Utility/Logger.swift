import Foundation
import OSLog

public let logger = CustomLogger()

public struct CustomLogger {

    #if DEBUG
    private let logger = Logger(subsystem: "taichi.satou.TimeWatcher", category: "DEBUG CONFIG")
    #else
    private let logger = Logger(subsystem: "taichi.satou.TimeWatcher", category: "PRD CONFIG")
    #endif

    public func debug(_ message: String, file: String = #fileID, function: String = #function, line: Int = #line) {

        logger.debug("🟩 [DEBUG] [\(file):\(function) \(line)]: \(message)")
    }

    public func info(_ message: String, file: String = #fileID, function: String = #function, line: Int = #line) {

        logger.info("🟪 [INFO] [\(file):\(function) \(line)]: \(message)")
    }

    public func warning(_ message: String, file: String = #fileID, function: String = #function, line: Int = #line) {

        logger.warning("🟨 [WARNING] [\(file):\(function) \(line)]: \(message)")
    }

    public func error(_ message: String, file: String = #fileID, function: String = #function, line: Int = #line) {

        logger.error("🟥 [ERROR] [\(file):\(function) \(line)]: \(message)")
    }
}
