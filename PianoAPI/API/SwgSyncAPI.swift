import Foundation

@objc(PianoAPISwgSyncAPI)
public class SwgSyncAPI: NSObject {

    /// Swg subscriptions
    /// - Parameters:
    ///   - aid: Application aid
    ///   - accessToken: Access token
    ///   - callback: Operation callback
    @objc public func syncExternal(
        aid: String,
        accessToken: String,
        completion: @escaping (JSONValue?, Error?) -> Void) {
        guard let client = PianoAPI.shared.client else {
            completion(nil, PianoAPIError("PianoAPI not initialized"))
            return
        }

        var params = [String:String]()
        params["aid"] = aid
        params["access_token"] = accessToken
        client.request(
            path: "/api/v3/swg/sync/external",
            method: PianoAPI.HttpMethod.from("GET"),
            params: params,
            completion: completion
        )
    }
}
