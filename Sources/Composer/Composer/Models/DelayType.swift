import Foundation

@objc public enum DelayType: Int {
    
    case time
    case scroll
    
    init(name: String) {
        switch name {
        case DelayType.time.description:
            self = .time
        case DelayType.scroll.description:
            self = .scroll
        default:
            self = .time
        }
    }
}

extension DelayType: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .time:
            return "time"
        case .scroll:
            return "scroll"
        }
    }
}
