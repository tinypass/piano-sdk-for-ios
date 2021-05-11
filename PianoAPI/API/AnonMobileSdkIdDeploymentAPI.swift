import Foundation

@objc(PianoAPIAnonMobileSdkIdDeploymentAPI)
public class AnonMobileSdkIdDeploymentAPI: NSObject {

    /// Returns the Piano ID deployment host
    /// - Parameters:
    ///   - aid: Application aid
    ///   - callback: Operation callback
    @objc public func deploymentHost(
        aid: String,
        completion: @escaping (String?, Error?) -> Void) {
        guard let client = PianoAPI.shared.client else {
            completion(nil, PianoAPIError("PianoAPI not initialized"))
            return
        }

        var params = [String:String]()
        params["aid"] = aid
        client.request(
            path: "/api/v3/anon/mobile/sdk/id/deployment/host",
            method: PianoAPI.HttpMethod.from("GET"),
            params: params,
            completion: completion
        )
    }
}
