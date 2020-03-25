import Foundation

extension TimeInterval {
    public func toMillis() -> Int64 {
        return (Int64)(self * 1000.0)
    }
}

extension Date {
    public func toUnixTimestamp() -> Int64 {
        return (Int64)(self.timeIntervalSince1970 * 1000.0)
    }
}
