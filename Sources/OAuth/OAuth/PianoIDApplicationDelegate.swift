import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn

@objcMembers
public class PianoIDApplicationDelegate: NSObject {
    
    public static let shared = PianoIDApplicationDelegate()
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if PianoID.shared.useNativeFacebookSignInSDK {
            FBSDKLoginKit.ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
        
        return true
    }
        
    public func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        var handled = PianoID.shared.handleUrl(url)
        
        if (!handled && PianoID.shared.useNativeGoogleSignInSDK) {
            handled = GoogleSignIn.GIDSignIn.sharedInstance().handle(url)
        }
        
        return handled
    }

    public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        var handled = PianoID.shared.handleUrl(url)
        
        if (!handled && PianoID.shared.useNativeGoogleSignInSDK) {
            handled = GoogleSignIn.GIDSignIn.sharedInstance().handle(url)
        }
        
        if (!handled && PianoID.shared.useNativeFacebookSignInSDK) {
            handled = FBSDKLoginKit.ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        
        return handled
    }

    public func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var handled = PianoID.shared.handleUrl(url)
        
        if (!handled && PianoID.shared.useNativeGoogleSignInSDK) {
            handled = GoogleSignIn.GIDSignIn.sharedInstance().handle(url)
        }
        
        if (!handled && PianoID.shared.useNativeFacebookSignInSDK) {
            handled = FBSDKLoginKit.ApplicationDelegate.shared.application(application, open: url, options: options)
        }
        
        return handled
    }
}
