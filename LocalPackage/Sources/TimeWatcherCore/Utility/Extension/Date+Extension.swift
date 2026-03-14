import Foundation

extension Date {

    public var timeIntervalSince1970MiliSec: TimeInterval {

        return self.timeIntervalSince1970 * 1000
    }

    /// yyyy/mm/dd hh:mm:ss.sss形式で文字列変換
    public func toStringDate() -> String {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS"
        return formatter.string(from: self)
    }
}
