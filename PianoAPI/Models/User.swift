import Foundation

@objc(PianoAPIUser)
public class User: NSObject, Codable {

    /// User&#39;s UID
    @objc public var uid: String? = nil

    /// User&#39;s email address
    @objc public var email: String? = nil

    /// User&#39;s first name
    @objc public var firstName: String? = nil

    /// User&#39;s last name
    @objc public var lastName: String? = nil

    /// User&#39;s personal name
    @objc public var personalName: String? = nil

    /// User creation date
    @objc public var createDate: Date? = nil

    public enum CodingKeys: String, CodingKey {
        case uid = "uid"
        case email = "email"
        case firstName = "first_name"
        case lastName = "last_name"
        case personalName = "personal_name"
        case createDate = "create_date"
    }
}
