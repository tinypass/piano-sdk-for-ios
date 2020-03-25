import Foundation

public class XpAccessItem: NSObject {

    public let rid: String
    
    public let resourceName: String
    
    fileprivate(set) public var expireDate: Int64 = 0
    
    fileprivate(set) public var daysUntilExpiration: Int64 = 0
    
    public init(dict: [String: Any]) {
        rid = dict["rid"] as? String ?? ""
        resourceName = dict["resourceName"] as? String ?? ""
        expireDate = dict["expireDate"] as? Int64 ?? 0
        daysUntilExpiration = dict["daysUntilExpiration"] as? Int64 ?? 0
    }
}
