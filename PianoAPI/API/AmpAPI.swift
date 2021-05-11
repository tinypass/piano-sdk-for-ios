import Foundation

@objc(PianoAPIAmpAPI)
public class AmpAPI: NSObject {

    /// Login AMP user to publisher site
    /// - Parameters:
    ///   - readerId: AMP reader id
    ///   - aid: Application aid
    ///   - userToken: User token
    ///   - userProvider: User token provider
    ///   - userRef: Encrypted user reference
    ///   - userTransient: User is transient and does not require validation
    ///   - userState: AMP user state
    ///   - callback: Operation callback
    @objc public func login(
        readerId: String,
        aid: String,
        userToken: String? = nil,
        userProvider: String? = nil,
        userRef: String? = nil,
        userTransient: OptionalBool = false,
        userState: String? = nil,
        completion: @escaping (Error?) -> Void) {
        guard let client = PianoAPI.shared.client else {
            completion(PianoAPIError("PianoAPI not initialized"))
            return
        }

        var params = [String:String]()
        params["reader_id"] = readerId
        params["aid"] = aid
        if let v = userToken { params["user_token"] = v }
        if let v = userProvider { params["user_provider"] = v }
        if let v = userRef { params["user_ref"] = v }
        params["user_transient"] = String(userTransient.value)
        if let v = userState { params["user_state"] = v }
        client.request(
            path: "/api/v3/amp/login",
            method: PianoAPI.HttpMethod.from("POST"),
            params: params,
            completion: completion
        )
    }

    /// Logout AMP user from publisher site
    /// - Parameters:
    ///   - readerId: AMP reader id
    ///   - aid: Application aid
    ///   - callback: Operation callback
    @objc public func logout(
        readerId: String,
        aid: String,
        completion: @escaping (Error?) -> Void) {
        guard let client = PianoAPI.shared.client else {
            completion(PianoAPIError("PianoAPI not initialized"))
            return
        }

        var params = [String:String]()
        params["reader_id"] = readerId
        params["aid"] = aid
        client.request(
            path: "/api/v3/amp/logout",
            method: PianoAPI.HttpMethod.from("POST"),
            params: params,
            completion: completion
        )
    }
}
