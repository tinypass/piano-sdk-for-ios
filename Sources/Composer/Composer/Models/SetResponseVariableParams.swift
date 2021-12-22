import Foundation

@objcMembers
public class SetResponseVariableParams: NSObject {
    
    public let variables: [String:Any]
    
    init?(dict: [String: Any]?) {
        guard let d = dict, let v = d["responseVariables"] as? [String:Any] else {
            return nil
        }
        variables = v
    }
}
