import Foundation

internal enum JSMessageHandlerType: Int {
    case unknown
    case close
    case closeAndRefresh
    case register
    case login
    case logout
    case customEvent
    
    internal static func fromString(value: String) -> JSMessageHandlerType {
        switch value {
        case JSMessageHandlerType.close.description:
            return .close
        case JSMessageHandlerType.closeAndRefresh.description:
            return .closeAndRefresh
        case JSMessageHandlerType.register.description:
            return .register
        case JSMessageHandlerType.login.description:
            return .login
        case JSMessageHandlerType.logout.description:
            return .logout
        case JSMessageHandlerType.customEvent.description:
            return .customEvent
        default:
            return .unknown
        }
    }
}

extension JSMessageHandlerType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return "unknown"
        case .close:
            return "close"
        case .closeAndRefresh:
            return "closeAndRefresh"
        case .register:
            return "register"
        case .login:
            return "login"
        case .logout:
            return "logout"
        case .customEvent:
            return "customEvent"
        }
    }
}
