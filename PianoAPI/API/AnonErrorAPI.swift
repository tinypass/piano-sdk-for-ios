import Foundation

@objc(PianoAPIAnonErrorAPI)
public class AnonErrorAPI: NSObject {

    /// Logs error to database
    /// - Parameters:
    ///   - logMessage: 
    ///   - callback: Operation callback
    @objc public func logError(
        logMessage: String,
        completion: @escaping (Error?) -> Void) {
        guard let client = PianoAPI.shared.client else {
            completion(PianoAPIError("PianoAPI not initialized"))
            return
        }

        var params = [String:String]()
        params["log_message"] = logMessage
        client.request(
            path: "/api/v3/anon/error/log",
            method: PianoAPI.HttpMethod.from("GET"),
            params: params,
            completion: completion
        )
    }

    
    /// - Parameters:
    ///   - callback: Operation callback
    @objc public func logErrorPreFlight(
        completion: @escaping (Error?) -> Void) {
        guard let client = PianoAPI.shared.client else {
            completion(PianoAPIError("PianoAPI not initialized"))
            return
        }

        
        client.request(
            path: "/api/v3/anon/error/log",
            method: PianoAPI.HttpMethod.from("OPTIONS"),
            completion: completion
        )
    }
}
