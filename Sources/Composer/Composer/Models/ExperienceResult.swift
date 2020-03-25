import Foundation

internal class ExperienceResult: NSObject {
    
    fileprivate(set) internal var debugMessages: Array<String>
    
    fileprivate(set) internal var events: Array<XpEvent>
    
    internal init(dict: [String: Any]) {
        debugMessages = Array<String>()
        if let debugMessagesArray = dict["debugMessages"] as? [Any] {
            for item in debugMessagesArray {
                if let str = item as? String {
                    debugMessages.append(str)
                }
            }
        }
        
        events = Array<XpEvent>()
        if let eventsArray = dict["events"] as? [Any] {
            for item in eventsArray {
                if let eventDict = item as? [String: Any] {
                    events.append(XpEvent(dict: eventDict))
                }
            }
        }
    }
}
