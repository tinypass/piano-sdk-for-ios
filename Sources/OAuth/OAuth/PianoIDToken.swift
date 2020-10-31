import Foundation

@objcMembers
public class PianoIDToken: NSObject, NSCoding {
                
    public let accessToken: String
    public let refreshToken: String
    public let expiresIn: Int64
    public let expirationDate: Date
    
    public var isExpired: Bool {
        return expirationDate > Date()
    }
    
    public init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
                
        do {
            let jwt = try decode(jwt: accessToken)
            self.expiresIn = Int64(jwt.expiresAt?.timeIntervalSince1970 ?? 0)
            self.expirationDate = jwt.expiresAt ?? Date(timeIntervalSince1970: 0)
        } catch {
            print("Cannot parse JWT token: \(error)")
            self.expiresIn = 0
            self.expirationDate = Date(timeIntervalSince1970: 0)
        }
    }
    
    public required convenience init?(coder: NSCoder) {
        let accessToken = coder.decodeObject(forKey: "access_token") as! String
        let refreshToken = coder.decodeObject(forKey: "refresh_token") as! String
        
        self.init(accessToken: accessToken, refreshToken: refreshToken)
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(accessToken, forKey: "access_token")
        coder.encode(refreshToken, forKey: "refresh_token")
    }           
}
