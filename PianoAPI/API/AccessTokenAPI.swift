import Foundation

@objc(PianoAPIAccessTokenAPI)
public class AccessTokenAPI: NSObject {

    /// Returns the list of access tokens
    /// - Parameters:
    ///   - aid: Application aid
    ///   - url: The URL of the page
    ///   - userToken: User token
    ///   - userProvider: User token provider
    ///   - userRef: Encrypted user reference
    ///   - callback: Operation callback
    @objc public func tokenList(
        aid: String,
        url: String? = nil,
        userToken: String? = nil,
        userProvider: String? = nil,
        userRef: String? = nil,
        completion: @escaping (AccessTokenList?, Error?) -> Void) {
        guard let client = PianoAPI.shared.client else {
            completion(nil, PianoAPIError("PianoAPI not initialized"))
            return
        }

        var params = [String:String]()
        params["aid"] = aid
        if let v = url { params["url"] = v }
        if let v = userToken { params["user_token"] = v }
        if let v = userProvider { params["user_provider"] = v }
        if let v = userRef { params["user_ref"] = v }
        client.request(
            path: "/api/v3/access/token/list",
            method: PianoAPI.HttpMethod.from("GET"),
            params: params,
            completion: completion
        )
    }

    
    /// - Parameters:
    ///   - callback: Operation callback
    @objc public func tokenListPreFlight(
        completion: @escaping (Error?) -> Void) {
        guard let client = PianoAPI.shared.client else {
            completion(PianoAPIError("PianoAPI not initialized"))
            return
        }

        
        client.request(
            path: "/api/v3/access/token/list",
            method: PianoAPI.HttpMethod.from("OPTIONS"),
            completion: completion
        )
    }
}
