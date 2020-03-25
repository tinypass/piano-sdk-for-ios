import Foundation

public class XpEventModuleParams: NSObject {
    
    public let moduleId: String
    
    public let moduleName: String
    
    public init(dict: [String: Any]) {
        moduleId = dict["moduleId"] as? String ?? ""
        moduleName = dict["moduleName"] as? String ?? ""
    }
}
