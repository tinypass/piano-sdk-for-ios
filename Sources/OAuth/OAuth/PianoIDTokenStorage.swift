import UIKit
import Security

@objcMembers
class PianoIDTokenStorage: NSObject {
    
    public static let shared = PianoIDTokenStorage()
    
    private let tokenKey: String = "io.piano.id.token"
    
    func saveToken(_ token: PianoIDToken, aid: String) -> Bool {
        removeToken(aid: aid)
        
        let tokenData = NSKeyedArchiver.archivedData(withRootObject: token)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrGeneric as String: tokenKey,
            kSecAttrAccount as String: aid,
            kSecValueData as String: tokenData
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func loadToken(aid: String) -> PianoIDToken? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrGeneric as String: tokenKey,
            kSecAttrAccount as String: aid,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let tokenData = item?.value(forKey: kSecValueData as String) as? Data else {
            return nil
        }
                
        return NSKeyedUnarchiver.unarchiveObject(with: tokenData) as? PianoIDToken
    }
    
    func removeToken(aid: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrGeneric as String: tokenKey,
            kSecAttrAccount as String: aid            
        ]
        
        _ = SecItemDelete(query as CFDictionary)
    }
}
