import FBSDKCoreKit
import FBSDKLoginKit

extension PianoID {
    
    internal func facebookSignIn() {
        DispatchQueue.main.async {
            FBSDKLoginKit.LoginManager().logIn(
                permissions: [.publicProfile, .email],
                viewController: self.authViewController,
                completion: self.facebookSignInCompleted
            )
        }
    }
    
    private func facebookSignInCompleted(result: FBSDKLoginKit.LoginResult) {
        switch result {
        case .cancelled:
            signInCancel()
        case .failed(let error):
            handleFacebookError(error)
        case .success(_, _, let token):
            handleFacebook(token: token.tokenString)
        }
    }
    
    private func handleFacebook(token: String) {
        authViewController?.socialSignInCallback(aid: getAID(), oauthProvider: "facebook", socialToken: token)
    }
    
    private func handleFacebookError(_ error: Error) {
        logError("Facebook sign in failed with error \(error)")
        signInFail(.facebookSignInFailed)
    }

}

extension PianoIDApplicationDelegate {
    
    internal func facebookApplication(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) {
        FBSDKLoginKit.ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }        

    internal func facebookApplication(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKLoginKit.ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    internal func facebookApplication(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKLoginKit.ApplicationDelegate.shared.application(application, open: url, options: options)
    }
}
