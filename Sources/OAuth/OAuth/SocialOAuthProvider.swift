import Foundation

@objc
public enum SocialOAuthProvider: Int {
    case google
    case facebook
    case linkedin
    case twitter
    case apple
}

extension SocialOAuthProvider: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .google:
            return "google"
        case .facebook:
            return "facebook"
        case .linkedin:
            return "linkedin"
        case .twitter:
            return "twitter"
        case .apple:
            return "apple"
        }
    }
}
