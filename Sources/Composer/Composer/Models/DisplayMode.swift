import Foundation

@objc public enum DisplayMode: Int {
    
    case inline
    case modal
    
    init(name: String) {
        switch name {
        case DisplayMode.inline.description:
            self = .inline
        case DisplayMode.modal.description:
            self = .modal
        default:
            self = .modal
        }
    }
}

extension DisplayMode: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .inline:
            return "inline"
        case .modal:
            return "modal"
        }
    }
}
