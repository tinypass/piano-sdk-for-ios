import AuthenticationServices

@available(iOS 13.0, *)
extension PianoID {

    internal func appleSignIn() {
        DispatchQueue.main.async {
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }
        
    private func handleApple(_ credential: ASAuthorizationAppleIDCredential) {        
        if let identityTokenData = credential.identityToken, let authorizationCodeData = credential.authorizationCode {
            let appleIdentitytoken = String(data: identityTokenData, encoding: .utf8) ?? ""
            let appleAuthorizationCode = String(data: authorizationCodeData, encoding: .utf8) ?? ""
            var params: [String: Any] = ["code" : appleAuthorizationCode]
            if let firstName = credential.fullName?.givenName, let lastName = credential.fullName?.familyName {
                params["firstName"] = firstName
                params["lastName"] = lastName
            }
            
            authViewController?.socialSignInCallback(aid: getAID(), oauthProvider: "apple", socialToken: appleIdentitytoken, params: params)
        }
    }
    
    private func handleAppleError(_ error: Error) {
        logError("Apple sign in failed with error \(error)")
        signInFail(.facebookSignInFailed)
    }
    
}

@available(iOS 13.0, *)
extension PianoID: ASAuthorizationControllerPresentationContextProviding {
    
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.presentingViewController?.view.window
            ?? (self.delegate as? UIViewController)?.view.window
            ?? UIApplication.shared.keyWindow
            ?? ASPresentationAnchor()
    }
}

@available(iOS 13.0, *)
extension PianoID: ASAuthorizationControllerDelegate {
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        handleAppleError(error)
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            handleApple(credential)
        }
    }
}

extension PianoIDApplicationDelegate {

    internal func appleApplication(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) {
    }
}
