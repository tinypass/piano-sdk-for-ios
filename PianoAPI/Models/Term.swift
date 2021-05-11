import Foundation

@objc(PianoAPITerm)
public class Term: NSObject, Codable {

    /// Term ID
    @objc public var termId: String? = nil

    /// Application aid
    @objc public var aid: String? = nil

    /// The resource
    @objc public var resource: Resource? = nil

    /// Term type
    @objc public var type: String? = nil

    /// Term name
    @objc public var name: String? = nil

    /// Term description
    @objc public var _description: String? = nil

    /// The creation date
    @objc public var createDate: Date? = nil

    public enum CodingKeys: String, CodingKey {
        case termId = "term_id"
        case aid = "aid"
        case resource = "resource"
        case type = "type"
        case name = "name"
        case _description = "description"
        case createDate = "create_date"
    }
}
