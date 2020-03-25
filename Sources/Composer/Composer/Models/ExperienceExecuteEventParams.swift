import Foundation

public class ExperienceExecuteEventParams: NSObject {
    
    fileprivate(set) public var accessList: Array<XpAccessItem>
    
    fileprivate(set) public var user: User? = nil
    
    init?(dict: [String: Any]?) {
        if dict == nil {
            return nil
        }
        
        accessList = Array<XpAccessItem>()
        if let accessListArray = dict!["accessList"] as? [Any] {
            for item in accessListArray {
                if let xpAccessItemDict = item as? [String: Any] {
                    accessList.append(XpAccessItem(dict: xpAccessItemDict))
                }
            }
        }
        
        if let userDict = dict!["user"] as? [String: Any] {
            user = User(dict: userDict)
        }
    }
}
