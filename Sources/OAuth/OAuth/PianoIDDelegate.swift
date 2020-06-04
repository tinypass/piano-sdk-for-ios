import Foundation

@objc
public protocol PianoIDDelegate: class {
    
    @objc func pianoID(_ pianoID: PianoID, didSignInForToken token: PianoIDToken!, withError error: Error!)        
    
    @objc func pianoID(_ pianoID: PianoID, didSignOutWithError error: Error!)
    
    @objc func pianoIDSignInDidCancel(_ pianoID: PianoID)
}
