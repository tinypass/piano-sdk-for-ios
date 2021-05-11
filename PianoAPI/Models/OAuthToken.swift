import Foundation

@objc(PianoAPIOAuthToken)
public class OAuthToken: NSObject, Codable {

    /// access_token
    @objc public var accessToken: String? = nil

    /// expires_in
    @objc public var expiresIn: OptionalInt? = nil

    /// refresh_token
    @objc public var refreshToken: String? = nil

    /// token_type
    @objc public var tokenType: String? = nil

    public enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
    }
}
