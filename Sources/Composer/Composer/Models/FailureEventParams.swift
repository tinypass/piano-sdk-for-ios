import Foundation

public class FailureEventParams: NSObject {
    
    public let moduleId: String
    
    public let moduleType: String
    
    public let moduleName: String
    
    public let errorMessage: String
    
    init?(dict: [String: Any]?) {
        if dict == nil {
            return nil
        }
        
        moduleId = dict!["moduleId"] as? String ?? ""
        moduleType = dict!["moduleType"] as? String ?? ""
        moduleName = dict!["moduleName"] as? String ?? ""
        errorMessage = dict!["errorMessage"] as? String ?? ""
    }
}
