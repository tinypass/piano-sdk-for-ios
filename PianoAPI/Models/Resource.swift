import Foundation

@objc(PianoAPIResource)
public class Resource: NSObject, Codable {

    /// Unique id for resource
    @objc public var rid: String? = nil

    /// Application aid
    @objc public var aid: String? = nil

    /// The name
    @objc public var name: String? = nil

    /// Resource description
    @objc public var _description: String? = nil

    /// Resource image URL
    @objc public var imageUrl: String? = nil

    public enum CodingKeys: String, CodingKey {
        case rid = "rid"
        case aid = "aid"
        case name = "name"
        case _description = "description"
        case imageUrl = "image_url"
    }
}
