import Foundation

internal class ExternalEventService {
    
    internal static let sharedInstance = ExternalEventService()
    
    fileprivate let userAgent = ComposerHelper.generateUserAgent()
    fileprivate let logAction = "/api/v3/conversion/logAutoMicroConversion"
    fileprivate let session: URLSession
    
    fileprivate init() {
        session = ExternalEventService.createSession()
    }
    
    fileprivate static func createSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.httpCookieStorage = nil
        config.httpCookieAcceptPolicy = .never
        return URLSession(configuration: config)
    }
    
    func logExternalEvent(endpointUrl: String, trackingId: String, eventType: String, eventGroupId: String, customParams: String) {
        guard let requestUrl = URL(string: "\(endpointUrl)\(logAction)") else {
           return
        }
        
        let requestBody = RequestParamBuilder()
            .add(name: "tracking_id", value: trackingId)
            .add(name: "event_type", value: eventType)
            .add(name: "event_group_id", value: eventGroupId)
            .add(name: "custom_params", value: customParams)
            .build().data(using: String.Encoding.utf8)
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.httpBody = requestBody
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        
        let dataTask = session.dataTask(with: request)
        dataTask.resume()
    }
}
