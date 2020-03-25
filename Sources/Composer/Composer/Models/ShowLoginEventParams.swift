import Foundation

public class ShowLoginEventParams: NSObject {
    
    public let userProvider: String
    
    init?(dict: [String: Any]?) {
        if dict == nil {
            return nil
        }
        
        userProvider = dict!["userProvider"] as? String ?? ""
    }
}
