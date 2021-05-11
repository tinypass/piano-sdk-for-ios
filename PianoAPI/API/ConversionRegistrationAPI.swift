import Foundation

@objc(PianoAPIConversionRegistrationAPI)
public class ConversionRegistrationAPI: NSObject {

    /// Creates registration term conversion
    /// - Parameters:
    ///   - aid: Application aid
    ///   - termId: Term ID
    ///   - userToken: User token
    ///   - userProvider: User token provider
    ///   - userRef: Encrypted user reference
    ///   - tbc: The Piano browser cookie (tbc)
    ///   - callback: Operation callback
    @objc public func createRegistrationConversion(
        aid: String,
        termId: String,
        userToken: String? = nil,
        userProvider: String? = nil,
        userRef: String? = nil,
        tbc: String? = nil,
        completion: @escaping (TermConversion?, Error?) -> Void) {
        guard let client = PianoAPI.shared.client else {
            completion(nil, PianoAPIError("PianoAPI not initialized"))
            return
        }

        var params = [String:String]()
        params["aid"] = aid
        params["term_id"] = termId
        if let v = userToken { params["user_token"] = v }
        if let v = userProvider { params["user_provider"] = v }
        if let v = userRef { params["user_ref"] = v }
        if let v = tbc { params["tbc"] = v }
        client.request(
            path: "/api/v3/conversion/registration/create",
            method: PianoAPI.HttpMethod.from("GET"),
            params: params,
            completion: completion
        )
    }
}
