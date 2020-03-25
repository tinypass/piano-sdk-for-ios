import Foundation

public class XpEventExecutionContext: NSObject {
    
    public let experienceId: String
    
    public let executionId: String
    
    public let trackingId: String
    
    fileprivate(set) public var splitTestEntries: Array<SplitTestEntry>
    
    public let currentMeterName: String
    
    fileprivate(set) public var user: User? = nil
    
    public let region: String
    
    public let countryCode: String
    
    fileprivate(set) public var accessList: Array<XpAccessItem>
    
    fileprivate(set) public var activeMeters: Array<Meter>
    
    public init(dict: [String: Any]) {
        experienceId = dict["experienceId"] as? String ?? ""
        executionId = dict["executionId"] as? String ?? ""
        trackingId = dict["trackingId"] as? String ?? ""
        currentMeterName = dict["currentMeterName"] as? String ?? ""
        region = dict["region"] as? String ?? ""
        countryCode = dict["countryCode"] as? String ?? ""
        
        splitTestEntries = Array<SplitTestEntry>()
        if let splitTestArray = dict["splitTests"] as? [Any] {
            for item in splitTestArray {
                if let splitTestEntryDict = item as? [String: Any] {
                    splitTestEntries.append(SplitTestEntry(dict: splitTestEntryDict))
                }
            }
        }
        
        accessList = Array<XpAccessItem>()
        if let accessListArray = dict["accessList"] as? [Any] {
            for item in accessListArray {
                if let xpAccessItemDict = item as? [String: Any] {
                    accessList.append(XpAccessItem(dict: xpAccessItemDict))
                }
            }
        }
        
        activeMeters = Array<Meter>()
        if let activeMetersArray = dict["activeMeters"] as? [Any] {
            for item in activeMetersArray {
                if let meterItemDict = item as? [String: Any] {
                    activeMeters.append(Meter(dict: meterItemDict))
                }
            }
        }
        
        if let userDict = dict["user"] as? [String: Any] {
            user = User(dict: userDict)
        }
    }
}
