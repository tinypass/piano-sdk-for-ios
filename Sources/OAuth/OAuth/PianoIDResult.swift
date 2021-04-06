import Foundation

@objcMembers
public class PianoIDSignInResult: NSObject {
   public let token: PianoIDToken
   public let isNewUser: Bool

   internal init(_ token: PianoIDToken, _ isNewUser: Bool) {
       self.token = token
       self.isNewUser = isNewUser
   }
}
