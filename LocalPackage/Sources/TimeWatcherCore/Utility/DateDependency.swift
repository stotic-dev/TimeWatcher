import Foundation

public final class DateDependency: @unchecked Sendable {

    public var now: Date?
    private let isTest: Bool

    public init(now: Date? = nil, isTest: Bool = false) {

        self.now = now
        self.isTest = isTest
    }

    public func generateNow() -> Date {

        return isTest ? now ?? Date.now : Date.now
    }
}
