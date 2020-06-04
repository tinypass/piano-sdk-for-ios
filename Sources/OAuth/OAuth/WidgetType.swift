import Foundation

@objc
public enum WidgetType : Int {
    case login
    case register
}

extension WidgetType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .login:
            return "login"
        case .register:
            return "register"
        }
    }
}
