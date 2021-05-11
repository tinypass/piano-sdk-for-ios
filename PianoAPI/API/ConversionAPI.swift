import Foundation

@objc(PianoAPIConversionAPI)
public class ConversionAPI: NSObject {

    /// Returns the list of term conversions for user
    /// - Parameters:
    ///   - aid: Application aid
    ///   - offset: Offset from which to start returning results
    ///   - limit: Maximum index of returned results
    ///   - userToken: User token
    ///   - userProvider: User token provider
    ///   - userRef: Encrypted user reference
    ///   - callback: Operation callback
    @objc public func list(
        aid: String,
        offset: OptionalInt = 0,
        limit: OptionalInt = 100,
        userToken: String? = nil,
        userProvider: String? = nil,
        userRef: String? = nil,
        completion: @escaping ([TermConversion]?, Error?) -> Void) {
        guard let client = PianoAPI.shared.client else {
            completion(nil, PianoAPIError("PianoAPI not initialized"))
            return
        }

        var params = [String:String]()
        params["aid"] = aid
        params["offset"] = String(offset.value)
        params["limit"] = String(limit.value)
        if let v = userToken { params["user_token"] = v }
        if let v = userProvider { params["user_provider"] = v }
        if let v = userRef { params["user_ref"] = v }
        client.request(
            path: "/api/v3/conversion/list",
            method: PianoAPI.HttpMethod.from("GET"),
            params: params,
            completion: completion
        )
    }

    
    /// - Parameters:
    ///   - callback: Operation callback
    @objc public func logAutoMicroConversionPreFlight(
        completion: @escaping (Error?) -> Void) {
        guard let client = PianoAPI.shared.client else {
            completion(PianoAPIError("PianoAPI not initialized"))
            return
        }

        
        client.request(
            path: "/api/v3/conversion/logAutoMicroConversion",
            method: PianoAPI.HttpMethod.from("OPTIONS"),
            completion: completion
        )
    }

    /// Log third party conversion
    /// - Parameters:
    ///   - trackingId: Conversion tracking id
    ///   - termId: Term ID
    ///   - termName: Term name
    ///   - stepNumber: Checkout step number
    ///   - conversionCategory: Conversion category
    ///   - amount: Conversion amount
    ///   - currency: Conversion currency by ISO 4217 standard
    ///   - customParams: Custom parameters (any key-value pairs) to save (this value should be a valid JSON object)
    ///   - callback: Operation callback
    @objc public func logConversion(
        trackingId: String,
        termId: String,
        termName: String,
        stepNumber: OptionalInt? = nil,
        conversionCategory: String? = nil,
        amount: OptionalDouble? = nil,
        currency: String? = nil,
        customParams: String? = nil,
        completion: @escaping (Error?) -> Void) {
        guard let client = PianoAPI.shared.client else {
            completion(PianoAPIError("PianoAPI not initialized"))
            return
        }

        var params = [String:String]()
        params["tracking_id"] = trackingId
        params["term_id"] = termId
        params["term_name"] = termName
        if let v = stepNumber { params["step_number"] = String(v.value) }
        if let v = conversionCategory { params["conversion_category"] = v }
        if let v = amount { params["amount"] = String(v.value) }
        if let v = currency { params["currency"] = v }
        if let v = customParams { params["custom_params"] = v }
        client.request(
            path: "/api/v3/conversion/log",
            method: PianoAPI.HttpMethod.from("POST"),
            params: params,
            completion: completion
        )
    }

    /// Log funnel step
    /// - Parameters:
    ///   - trackingId: Conversion tracking id
    ///   - stepNumber: Checkout step number
    ///   - stepName: Checkout step name
    ///   - customParams: Custom parameters (any key-value pairs) to save (this value should be a valid JSON object)
    ///   - callback: Operation callback
    @objc public func logFunnelStep(
        trackingId: String,
        stepNumber: OptionalInt,
        stepName: String,
        customParams: String? = nil,
        completion: @escaping (Error?) -> Void) {
        guard let client = PianoAPI.shared.client else {
            completion(PianoAPIError("PianoAPI not initialized"))
            return
        }

        var params = [String:String]()
        params["tracking_id"] = trackingId
        params["step_number"] = String(stepNumber.value)
        params["step_name"] = stepName
        if let v = customParams { params["custom_params"] = v }
        client.request(
            path: "/api/v3/conversion/logFunnelStep",
            method: PianoAPI.HttpMethod.from("POST"),
            params: params,
            completion: completion
        )
    }

    /// Log micro conversion
    /// - Parameters:
    ///   - trackingId: Conversion tracking id
    ///   - eventGroupId: Event group
    ///   - customParams: Custom parameters (any key-value pairs) to save (this value should be a valid JSON object)
    ///   - callback: Operation callback
    @objc public func logMicroConversion(
        trackingId: String,
        eventGroupId: String,
        customParams: String? = nil,
        completion: @escaping (Error?) -> Void) {
        guard let client = PianoAPI.shared.client else {
            completion(PianoAPIError("PianoAPI not initialized"))
            return
        }

        var params = [String:String]()
        params["tracking_id"] = trackingId
        params["event_group_id"] = eventGroupId
        if let v = customParams { params["custom_params"] = v }
        client.request(
            path: "/api/v3/conversion/logMicroConversion",
            method: PianoAPI.HttpMethod.from("POST"),
            params: params,
            completion: completion
        )
    }
}
