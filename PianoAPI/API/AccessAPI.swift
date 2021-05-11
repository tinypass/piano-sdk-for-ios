import Foundation

@objc(PianoAPIAccessAPI)
public class AccessAPI: NSObject {

    /// Returns the access details for user and rid
    /// - Parameters:
    ///   - rid: Unique id for resource
    ///   - aid: Application aid
    ///   - tpAccessTokenV2: The Piano access token (v2)
    ///   - umc: The Piano user meter cookie (umc)
    ///   - crossApp: Provide cross application access for resource
    ///   - userToken: User token
    ///   - userProvider: User token provider
    ///   - userRef: Encrypted user reference
    ///   - callback: Operation callback
    @objc public func check(
        rid: String,
        aid: String,
        tpAccessTokenV2: String? = nil,
        umc: String? = nil,
        crossApp: OptionalBool = false,
        userToken: String? = nil,
        userProvider: String? = nil,
        userRef: String? = nil,
        completion: @escaping (AccessDTO?, Error?) -> Void) {
        guard let client = PianoAPI.shared.client else {
            completion(nil, PianoAPIError("PianoAPI not initialized"))
            return
        }

        var params = [String:String]()
        params["rid"] = rid
        params["aid"] = aid
        if let v = tpAccessTokenV2 { params["tp_access_token_v2"] = v }
        if let v = umc { params["umc"] = v }
        params["cross_app"] = String(crossApp.value)
        if let v = userToken { params["user_token"] = v }
        if let v = userProvider { params["user_provider"] = v }
        if let v = userRef { params["user_ref"] = v }
        client.request(
            path: "/api/v3/access/check",
            method: PianoAPI.HttpMethod.from("GET"),
            params: params,
            completion: completion
        )
    }

    /// Returns access list for user
    /// - Parameters:
    ///   - aid: Application aid
    ///   - offset: Offset from which to start returning results
    ///   - limit: Maximum index of returned results
    ///   - active: whether the object is active
    ///   - expandBundled: Expand bundled accesses
    ///   - crossApp: Provide cross application access for resource
    ///   - userToken: User token
    ///   - userProvider: User token provider
    ///   - userRef: Encrypted user reference
    ///   - callback: Operation callback
    @objc public func list(
        aid: String,
        offset: OptionalInt = 0,
        limit: OptionalInt = 100,
        active: OptionalBool = true,
        expandBundled: OptionalBool = false,
        crossApp: OptionalBool = false,
        userToken: String? = nil,
        userProvider: String? = nil,
        userRef: String? = nil,
        completion: @escaping ([AccessDTO]?, Error?) -> Void) {
        guard let client = PianoAPI.shared.client else {
            completion(nil, PianoAPIError("PianoAPI not initialized"))
            return
        }

        var params = [String:String]()
        params["aid"] = aid
        params["offset"] = String(offset.value)
        params["limit"] = String(limit.value)
        params["active"] = String(active.value)
        params["expand_bundled"] = String(expandBundled.value)
        params["cross_app"] = String(crossApp.value)
        if let v = userToken { params["user_token"] = v }
        if let v = userProvider { params["user_provider"] = v }
        if let v = userRef { params["user_ref"] = v }
        client.request(
            path: "/api/v3/access/list",
            method: PianoAPI.HttpMethod.from("GET"),
            params: params,
            completion: completion
        )
    }
}
