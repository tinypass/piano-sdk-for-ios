import Foundation

@objc(PianoAPIAnonAssetsAPI)
public class AnonAssetsAPI: NSObject {

    /// Get Google Analytics Tag
    /// - Parameters:
    ///   - aid: Application aid
    ///   - callback: Operation callback
    @objc public func gaAccount(
        aid: String,
        completion: @escaping (String?, Error?) -> Void) {
        guard let client = PianoAPI.shared.client else {
            completion(nil, PianoAPIError("PianoAPI not initialized"))
            return
        }

        var params = [String:String]()
        params["aid"] = aid
        client.request(
            path: "/api/v3/anon/assets/gaAccount",
            method: PianoAPI.HttpMethod.from("GET"),
            params: params,
            completion: completion
        )
    }

    /// Get Google Analytics Tag for Performance Metrics
    /// - Parameters:
    ///   - callback: Operation callback
    @objc public func performanceMetricsGAAccount(
        completion: @escaping (PerformanceMetricsDto?, Error?) -> Void) {
        guard let client = PianoAPI.shared.client else {
            completion(nil, PianoAPIError("PianoAPI not initialized"))
            return
        }

        
        client.request(
            path: "/api/v3/anon/assets/performanceMetrics",
            method: PianoAPI.HttpMethod.from("GET"),
            completion: completion
        )
    }
}
