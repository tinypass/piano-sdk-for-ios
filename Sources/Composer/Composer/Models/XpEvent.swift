import Foundation

public class XpEvent: NSObject {
    
    public let eventType: String
    
    internal let eventParams: [String: Any]?
    
    fileprivate(set) public var eventModuleParams: XpEventModuleParams? = nil
    
    fileprivate(set) public var eventExecutionContext: XpEventExecutionContext? = nil
    
    public init(dict: [String: Any]) {
        eventType = dict["eventType"] as? String ?? ""
        
        if let eventModuleParamsDict = dict["eventModuleParams"] as? [String: Any] {
            eventModuleParams = XpEventModuleParams(dict: eventModuleParamsDict)
        }
        
        if let eventExecutionContextDict = dict["eventExecutionContext"] as? [String: Any] {
            eventExecutionContext = XpEventExecutionContext(dict: eventExecutionContextDict)
        }
        
        eventParams = dict["eventParams"] as? [String: Any]
    }
}
