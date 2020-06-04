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
    
    private init(accessToken: String, refreshToken: String, expiresIn: Int64, expirationDate: Date) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
        self.expirationDate = expirationDate
    }
    
    public convenience init(accessToken: String, refreshToken: String, expiresIn: Int64) {
        let expirationDate = Date().addingTimeInterval(Double(expiresIn))
        self.init(accessToken: accessToken, refreshToken: refreshToken, expiresIn: expiresIn, expirationDate: expirationDate)
    }
    
    public required convenience init?(coder: NSCoder) {
        let accessToken = coder.decodeObject(forKey: "access_token") as! String
        let refreshToken = coder.decodeObject(forKey: "refresh_token") as! String
        let expiresIn = coder.decodeInt64(forKey: "expires_in")
        let expirationDate = coder.decodeObject(forKey: "expiration_date") as! Date
        
        self.init(accessToken: accessToken, refreshToken: refreshToken, expiresIn: expiresIn, expirationDate: expirationDate)
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(accessToken, forKey: "access_token")
        coder.encode(refreshToken, forKey: "refresh_token")
        coder.encode(expiresIn, forKey: "expires_in")
        coder.encode(expirationDate, forKey: "expiration_date")
    }           
}
