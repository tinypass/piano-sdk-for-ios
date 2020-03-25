import Foundation

public class DelayBy: NSObject {

    public let type: DelayType
    
    public let value: Int
    
    init(dict: [String: Any]) {
        value = dict["value"] as? Int ?? 0
        type = DelayType(name: (dict["type"] as? String ?? ""))
    }
}
