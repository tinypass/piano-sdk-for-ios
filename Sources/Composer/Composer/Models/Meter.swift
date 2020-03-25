import Foundation

public class Meter: NSObject {
    
    public let meterName: String
    
    fileprivate(set) public var views: Int = 0
    
    fileprivate(set) public var viewsLeft: Int = 0
    
    fileprivate(set) public var maxViews: Int = 0
    
    fileprivate(set) public var totalViews: Int = 0
    
    init(dict: [String: Any]) {
        meterName = dict["meterName"] as? String ?? ""
        views = dict["views"] as? Int ?? 0
        viewsLeft = dict["viewsLeft"] as? Int ?? 0
        maxViews = dict["maxViews"] as? Int ?? 0
        totalViews = dict["totalViews"] as? Int ?? 0
    }
    
    public func toDictionary() -> [String: Any] {
        return ["meterName": meterName,
                "views": views,
                "viewsLeft": viewsLeft,
                "maxViews": maxViews,
                "totalViews": totalViews]
    }
}
