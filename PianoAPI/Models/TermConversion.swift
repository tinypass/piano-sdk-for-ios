import Foundation

@objc(PianoAPITermConversion)
public class TermConversion: NSObject, Codable {

    /// Term conversion id
    @objc public var termConversionId: String? = nil

    /// The term that was converted
    @objc public var term: Term? = nil

    /// The term conversion type
    @objc public var type: String? = nil

    /// Application aid
    @objc public var aid: String? = nil

    /// The access that was created as a result of the term conversion
    @objc public var userAccess: Access? = nil

    /// The creation date
    @objc public var createDate: Date? = nil

    public enum CodingKeys: String, CodingKey {
        case termConversionId = "term_conversion_id"
        case term = "term"
        case type = "type"
        case aid = "aid"
        case userAccess = "user_access"
        case createDate = "create_date"
    }
}
