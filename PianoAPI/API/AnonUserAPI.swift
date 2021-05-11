import Foundation

@objc(PianoAPIAnonUserAPI)
public class AnonUserAPI: NSObject {

    /// Gets a user
    /// - Parameters:
    ///   - aid: Application aid
    ///   - userToken: User token
    ///   - userProvider: User token provider
    ///   - userRef: Encrypted user reference
    ///   - callback: Operation callback
    @objc public func callGet(
        aid: String,
        userToken: String? = nil,
        userProvider: String? = nil,
        userRef: String? = nil,
        completion: @escaping (User?, Error?) -> Void) {
        guard let client = PianoAPI.shared.client else {
            completion(nil, PianoAPIError("PianoAPI not initialized"))
            return
        }

        var params = [String:String]()
        params["aid"] = aid
        if let v = userToken { params["user_token"] = v }
        if let v = userProvider { params["user_provider"] = v }
        if let v = userRef { params["user_ref"] = v }
        client.request(
            path: "/api/v3/anon/user/get",
            method: PianoAPI.HttpMethod.from("POST"),
            params: params,
            completion: completion
        )
    }
}
