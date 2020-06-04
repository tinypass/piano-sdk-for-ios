import GoogleSignIn

extension PianoID {
    
    internal func googleSignIn() {
        DispatchQueue.main.async {
            if let viewController = self.authViewController {
                GoogleSignIn.GIDSignIn.sharedInstance().presentingViewController = viewController
            }
            
            GoogleSignIn.GIDSignIn.sharedInstance().clientID = self.googleClientId
            GoogleSignIn.GIDSignIn.sharedInstance().scopes = ["profile", "email"]
            GoogleSignIn.GIDSignIn.sharedInstance().delegate = self
            GoogleSignIn.GIDSignIn.sharedInstance().signIn()
        }
    }
    
    private func handleGoogle(token: String) {
        authViewController?.socialSignInCallback(aid: getAID(), oauthProvider: "google", socialToken: token)
    }
    
    private func handleGoogleError(_ error: NSError) {
        if error.code == GIDSignInErrorCode.canceled.rawValue {
            signInCancel()
        } else {
            logError("Google sign in failed with error \(error)")
            signInFail(.googleSignInFailed)
        }
    }
}

extension PianoID: GoogleSignIn.GIDSignInDelegate {
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil {
            handleGoogle(token: user.authentication.idToken)
        } else {
            handleGoogleError(error as NSError)
        }
    }
}

extension PianoIDApplicationDelegate {
    
    internal func googleApplication(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return GoogleSignIn.GIDSignIn.sharedInstance().handle(url)
    }

    internal func googleApplication(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GoogleSignIn.GIDSignIn.sharedInstance().handle(url)
    }

    internal func googleApplication(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GoogleSignIn.GIDSignIn.sharedInstance().handle(url)        
    }
}
