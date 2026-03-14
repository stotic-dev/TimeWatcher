import Foundation

extension Calendar {

    public func date(byAdding components: [Calendar.Component: Int], to: Date) -> Date {

        return components.reduce(into: to) {

            $0 = self.date(byAdding: $1.key, value: $1.value, to: $0) ?? $0
        }
    }

    public func date(byAdding miliSec: Int, to: Date) -> Date {

        return Date(timeIntervalSince1970: (to.timeIntervalSince1970MiliSec + TimeInterval(miliSec)) / 1000)
    }
}
