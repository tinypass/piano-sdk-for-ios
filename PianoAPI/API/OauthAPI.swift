import Foundation

@objc(PianoAPIOauthAPI)
public class OauthAPI: NSObject {

    /// OAuth 2.0 authorize
    /// - Parameters:
    ///   - clientId: Client ID of OAuth authorize
    ///   - clientSecret: Client secret of OAuth authorize
    ///   - code: OAuth code of OAuth authorize
    ///   - refreshToken: OAuth refresh token of OAuth authorize
    ///   - grantType: Grant type of OAuth authorize
    ///   - redirectUri: Redirect URI of OAuth authorize
    ///   - username: Username
    ///   - password: Password
    ///   - state: State
    ///   - deviceId: Device ID
    ///   - callback: Operation callback
    @objc public func authToken(
        clientId: String,
        clientSecret: String? = nil,
        code: String? = nil,
        refreshToken: String? = nil,
        grantType: String? = nil,
        redirectUri: String? = nil,
        username: String? = nil,
        password: String? = nil,
        state: String? = nil,
        deviceId: String? = nil,
        completion: @escaping (OAuthToken?, Error?) -> Void) {
        guard let client = PianoAPI.shared.client else {
            completion(nil, PianoAPIError("PianoAPI not initialized"))
            return
        }

        var params = [String:String]()
        params["client_id"] = clientId
        if let v = clientSecret { params["client_secret"] = v }
        if let v = code { params["code"] = v }
        if let v = refreshToken { params["refresh_token"] = v }
        if let v = grantType { params["grant_type"] = v }
        if let v = redirectUri { params["redirect_uri"] = v }
        if let v = username { params["username"] = v }
        if let v = password { params["password"] = v }
        if let v = state { params["state"] = v }
        if let v = deviceId { params["device_id"] = v }
        client.request(
            path: "/api/v3/oauth/authToken",
            method: PianoAPI.HttpMethod.from("POST"),
            params: params,
            completion: completion
        )
    }
}
