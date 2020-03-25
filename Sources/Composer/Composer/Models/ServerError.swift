import Foundation

public class ServerError: NSObject {
    
    public let field: String
    
    public let key: String
    
    public let message: String
    
    init(dict: [String: Any]) {
        field = dict["field"] as? String ?? ""
        key = dict["key"] as? String ?? ""
        message = dict["msg"] as? String ?? ""
    }

}
