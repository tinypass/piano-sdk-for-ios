import Foundation

public class ShowTemplateEventParams: NSObject {

    public let templateId: String
    
    public let templateVariantId: String
    
    public let displayMode: DisplayMode
    
    internal var templateUrl: String = ""
    
    internal var trackingId: String = ""
    
    internal var endpointUrl: String = ""
    
    fileprivate(set) public var delayBy: DelayBy? = nil
    
    public let containerSelector: String
    
    public let showCloseButton: Bool
    
    init?(dict: [String: Any]?) {
        if dict == nil {
            return nil
        }
            
        templateId = dict!["templateId"] as? String ?? ""
        templateVariantId = dict!["templateVariantId"] as? String ?? ""
        displayMode = DisplayMode(name: (dict!["displayMode"] as? String ?? ""))
        containerSelector = dict!["containerSelector"] as? String ?? ""
        showCloseButton = dict!["showCloseButton"] as? Bool ?? false
        
        if let delayByDict = dict!["delayBy"] as? [String: Any] {
            delayBy = DelayBy(dict: delayByDict)
        }
    }
}
