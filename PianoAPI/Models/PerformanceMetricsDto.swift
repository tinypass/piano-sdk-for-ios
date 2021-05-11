import Foundation

@objc(PianoAPIPerformanceMetricsDto)
public class PerformanceMetricsDto: NSObject, Codable {

    /// GA Account
    @objc public var gaAccount: String? = nil

    /// Is GA enabled
    @objc public var isEnabled: String? = nil

    /// Track only aids
    @objc public var trackOnlyAids: String? = nil

    public enum CodingKeys: String, CodingKey {
        case gaAccount = "ga_account"
        case isEnabled = "is_enabled"
        case trackOnlyAids = "track_only_aids"
    }
}
