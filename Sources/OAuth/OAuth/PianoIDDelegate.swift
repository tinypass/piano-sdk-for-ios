import Foundation

@objc public protocol PianoIDDelegate: AnyObject {
    
    @objc optional func signIn(result: PianoIDSignInResult!, withError error: Error!);

    @objc optional func signOut(withError error: Error!);

    @objc optional func cancel();
    
    @objc optional func customEvent(event: [String: Any])
}
