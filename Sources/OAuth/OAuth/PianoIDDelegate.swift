import Foundation

@objc
public protocol PianoIDDelegate: class {
    
    @available(*, deprecated, message: "Implement PianoIDDelegate.signIn") func pianoID(_ pianoID: PianoID, didSignInForToken token: PianoIDToken!, withError error: Error!)

    @available(*, deprecated, message: "Implement PianoIDDelegate.signOut") func pianoID(_ pianoID: PianoID, didSignOutWithError error: Error!)

    @available(*, deprecated, message: "Implement PianoIDDelegate.cancel") func pianoIDSignInDidCancel(_ pianoID: PianoID)

    @objc optional func signIn(result: PianoIDSignInResult!, withError error: Error!);

    @objc optional func signOut(withError error: Error!);

    @objc optional func cancel();
    
    @objc optional func customEvent(event: [String: Any])
}
