import UIKit

@objcMembers
public class PianoIDApplicationDelegate: NSObject {
    
    public static let shared = PianoIDApplicationDelegate()
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {        
        facebookApplication(application, didFinishLaunchingWithOptions: launchOptions)
        appleApplication(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
        
    public func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        var handled = PianoID.shared.handleUrl(url)
        
        if (!handled) {
            handled = googleApplication(application, handleOpen: url)
        }
        
        return handled
    }

    public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        var handled = PianoID.shared.handleUrl(url)
        
        if (!handled) {
            handled = googleApplication(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        
        if (!handled) {
            handled = facebookApplication(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        
        return handled
    }

    public func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var handled = PianoID.shared.handleUrl(url)
        
        if (!handled) {
            handled = googleApplication(application, open: url, options: options)
        }
        
        if (!handled) {
            handled = facebookApplication(application, open: url, options: options)
        }
        
        return handled
    }
}
