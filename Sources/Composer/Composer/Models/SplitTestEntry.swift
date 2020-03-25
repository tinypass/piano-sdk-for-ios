import Foundation

public class SplitTestEntry: NSObject {
    
    public let splitTestVariantId: String
    
    public let splitTestVariantName: String
    
    public init(dict: [String: Any]) {
        splitTestVariantId = dict["variantId"] as? String ?? ""
        splitTestVariantName = dict["variantName"] as? String ?? ""
    }
}
