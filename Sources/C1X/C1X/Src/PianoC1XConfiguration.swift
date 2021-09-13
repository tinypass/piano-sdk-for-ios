import Foundation

/// Piano C1X integration configuration
public class PianoC1XConfiguration: NSObject {

    internal static let pageViewEventDelay: Int = 3
    internal static let eventLockDuration: Int64 = 60
    
    internal let siteId: String
    
    /// Create instance of PianoC1XConfiguration
    ///
    /// - Parameters:
    ///   - siteId: PageView event site identifier.
    public init(siteId: String) {
        self.siteId = siteId
    }
}
