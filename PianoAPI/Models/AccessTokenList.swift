import Foundation

@objc(PianoAPIAccessTokenList)
public class AccessTokenList: NSObject, Codable {

    /// The encoded access token list value
    @objc public var value: String? = nil

    /// The domain to set the cookie on
    @objc public var cookieDomain: String? = nil

    public enum CodingKeys: String, CodingKey {
        case value = "value"
        case cookieDomain = "cookie_domain"
    }
}
