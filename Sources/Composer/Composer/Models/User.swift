import Foundation

public class User: NSObject {
 
    public let uid: String
    
    public let firstName: String
    
    public let lastName: String
    
    public let email: String
    
    init(dict: [String: Any]) {
        uid = dict["uid"] as? String ?? ""
        firstName = dict["firstName"] as? String ?? ""
        lastName = dict["lastName"] as? String ?? ""
        email = dict["email"] as? String ?? ""
    }
}
