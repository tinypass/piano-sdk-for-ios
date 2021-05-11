import Foundation

@objc(PianoAPIConversionExternalAPI)
public class ConversionExternalAPI: NSObject {

    /// Records an external conversion
    /// - Parameters:
    ///   - aid: Application aid
    ///   - termId: Term ID
    ///   - fields: JSON object tht specify what fields have to be checked using external API
    ///   - userToken: User token
    ///   - userProvider: User token provider
    ///   - userRef: Encrypted user reference
    ///   - callback: Operation callback
    @objc public func externalVerifiedCreate(
        aid: String,
        termId: String,
        fields: String,
        userToken: String? = nil,
        userProvider: String? = nil,
        userRef: String? = nil,
        completion: @escaping (TermConversion?, Error?) -> Void) {
        guard let client = PianoAPI.shared.client else {
            completion(nil, PianoAPIError("PianoAPI not initialized"))
            return
        }

        var params = [String:String]()
        params["aid"] = aid
        params["term_id"] = termId
        params["fields"] = fields
        if let v = userToken { params["user_token"] = v }
        if let v = userProvider { params["user_provider"] = v }
        if let v = userRef { params["user_ref"] = v }
        client.request(
            path: "/api/v3/conversion/external/create",
            method: PianoAPI.HttpMethod.from("POST"),
            params: params,
            completion: completion
        )
    }
}
