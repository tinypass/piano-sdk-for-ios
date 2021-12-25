import Foundation

@objcMembers
public class ShowTemplateEventParams: NSObject {

    public let templateId: String
    
    public let templateVariantId: String
    
    public let displayMode: DisplayMode
    
    internal var templateUrl: String = ""
    
    internal var trackingId: String = ""
    
    internal var endpointUrl: String = ""
    
    fileprivate(set) public var delayBy: DelayBy? = nil
    
    public let containerSelector: String

    public var activityIndicatorBackgroundColor : UIColor? = nil
    
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
        activityIndicatorBackgroundColor = UIColor(red: 56 / 255.0, green: 120 / 255.0, blue: 212 / 255.0, alpha: 1)

        if let delayByDict = dict!["delayBy"] as? [String: Any] {
            delayBy = DelayBy(dict: delayByDict)
        }
    }
}
