import AuthenticationServices
import CommonCrypto
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import UIKit
import SafariServices

@objc public enum PianoIDError: Int, Error, CustomStringConvertible {
    
    case invalidAuthorizationUrl = -1
    case cannotGetDeploymentHost = -2
    case signInFailed = -3
    case signOutFailed = -4
    case googleSignInFailed = -5
    case facebookSignInFailed = -6
    
    public var description: String {
        switch self {
            case .invalidAuthorizationUrl:
                return "Invalid authorization URL"
            case .cannotGetDeploymentHost:
                return "Cannot get deployment host for application"
            case .signInFailed:
                return "Sign in failed"
            case .signOutFailed:
                return "Sign out failed"
            case .googleSignInFailed:
                return "Google sign in failed"
            case .facebookSignInFailed:
                return "Facebook sign in failed"
        }
    }
}

@objc public protocol PianoIDDelegate: class {
    
    @objc func pianoID(_ pianoID: PianoID, didSignInForToken token: PianoIDToken!, withError error: Error!)
    
    @objc func pianoID(_ pianoID: PianoID, didSignOutWithError error: Error!)
    
    @objc func pianoIDSignInDidCancel(_ pianoID: PianoID)
}

@objcMembers
public class PianoIDToken: NSObject {
    
    public let accessToken: String
    public let refreshToken: String
    public let expiresIn: Int64
    
    public init(accessToken: String, refreshToken: String, expiresIn: Int64) {        
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
    }
}

@objcMembers
public class PianoID: NSObject {
    
    private let sandbox = "https://sandbox.tinypass.com"
    private let idProd = "https://id.tinypass.com"
    private let apiProd = "https://buy.tinypass.com"
                
    private let deploymentHostPath = "/api/v3/anon/mobile/sdk/id/deployment/host"
    private let authorizationPath = "/id/api/v1/identity/vxauth/authorize"
    private let exchangeTokenPath = "/id/api/v1/identity/oauth/token"
    private let socialExchangeTokenPath = "/id/api/v1/identity/oauth/mobile/token"
    private let logoutPath = "/id/api/v1/identity/logout"
    
    private let urlSchemePrefix = "io.piano.id"
    private let urlSchemePath = "success"
    
    private let googleOAuthProviderName = "google"
    private let facebookOAuthProviderName = "facebook"
    
    public static let shared: PianoID = PianoID()

    public weak var delegate: PianoIDDelegate?
        
    public var aid: String = ""
    public var isSandbox = false
    public var endpointUrl: String = ""
    public var widgetType: WidgetType = .login
    public var signUpEnabled = false
    public var presentingViewController: UIViewController?
    public var forceSFSafariViewControllerUsage = false
    public var useNativeGoogleSignInSDK = false
    public var useNativeFacebookSignInSDK = false
    public var googleClientId: String = ""
    
    private var authSession: Any?
    private var urlSession: URLSession
    private var deploymentHost: String = ""
    private var authorizationCode: String?
    private var codeVerifier: String?
    
    private var redirectScheme: String {
        get {
            return "\(urlSchemePrefix).\(aid.lowercased())://"
        }
    }
    
    private var redirectURI: String {
        get {
            return "\(redirectScheme)\(urlSchemePath)"
        }
    }
    
    private var idHost: String {
        get {
            if endpointUrl.isEmpty {
                return isSandbox ? sandbox : idProd
            } else {
                return endpointUrl
            }
        }
    }
    
    private var apiHost: String {
        get {
            if endpointUrl.isEmpty {
                return isSandbox ? sandbox : apiProd
            } else {
                return endpointUrl
            }
        }
    }
    
    private override init() {
        let config = URLSessionConfiguration.default
        config.httpCookieStorage = nil
        config.httpCookieAcceptPolicy = .never
        urlSession = URLSession(configuration: config)
        super.init()
    }
    
    public func signIn() {
        authorizationCode = ""
        getDeploymentHost(
            success: { (host) in
                if let url = self.prepareAuthorizationUrl(host: host) {
                    self.startAuthSession(url: url)
                } else {
                    self.signInFail(.invalidAuthorizationUrl)
                }
        },
            fail: {
                self.signInFail(.cannotGetDeploymentHost)
        })
    }
    
    public func signOut(token: String) {
        if let url = prepareSignOutUrl(host: idHost, token: token) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let dataTask = urlSession.dataTask(with: request) { (data, response, error) in
                if error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    self.signOutSuccess()
                } else {
                    self.signOutFail()
                }
            }
            
            dataTask.resume()
        }
    }
    
    private func getDeploymentHost(success: @escaping (String) -> Void, fail: @escaping () -> Void) {
        if let url = prepareDeploymentHostUrl(host: apiHost) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let dataTask = urlSession.dataTask(with: request) { (data, response, error) in
                if error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let responseData = data {
                    if let responseObject = JSONSerializationUtil.deserializeResponse(response: response!, responseData: responseData), let host = responseObject["data"] as? String {
                        success(host.isEmpty ? self.idProd : host)
                        return
                    }
                }
                
                fail()
            }
            
            dataTask.resume()
        }
    }
          
    private func exchangeToken(code: String) {
        if let url = prepareExchangeTokenUrl(host: idHost) {
            let body: [String: Any] = [
                "client_id": aid,
                "code": code,
                "code_verifier": codeVerifier?.data(using: .utf8)?.base64EncodedString() ?? "",
                "grant_type": "authorization_code",
            ]
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = JSONSerializationUtil.serializeObjectToJSONData(object: body)
            let dataTask = urlSession.dataTask(with: request) { (data, response, error) in
                if error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let responseData = data {
                    if let responseObject = JSONSerializationUtil.deserializeResponse(response: response!, responseData: responseData) {
                        if let accessToken = responseObject["access_token"] as? String,
                            let refreshToken = responseObject["refresh_token"] as? String,
                            let expiresIn = responseObject["expires_in"]as? Int64 {
                            self.signInSuccess(PianoIDToken(accessToken: accessToken, refreshToken: refreshToken, expiresIn: expiresIn))
                            return
                        }
                    }
                }
                
                self.signInFail(PianoIDError.signInFailed)
            }
            
            dataTask.resume()
        }
    }
    
    private func exchangeSocialToken(socialToken: String) {
        if let url = prepareSocialExchangeTokenUrl(host: idHost) {
            let body: [String: Any] = [
                "client_id": aid,
                "code": authorizationCode ?? "",
                "code_verifier": codeVerifier?.data(using: .utf8)?.base64EncodedString() ?? "",
                "grant_type": "authorization_code",
                "provider_access_token": socialToken
            ]
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = JSONSerializationUtil.serializeObjectToJSONData(object: body)
            let dataTask = urlSession.dataTask(with: request) { (data, response, error) in                
                if error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let responseData = data {
                    if let responseObject = JSONSerializationUtil.deserializeResponse(response: response!, responseData: responseData) {
                        if let accessToken = responseObject["access_token"] as? String,
                            let refreshToken = responseObject["refresh_token"] as? String,
                            let expiresIn = responseObject["expires_in"]as? Int64 {
                            self.signInSuccess(PianoIDToken(accessToken: accessToken, refreshToken: refreshToken, expiresIn: expiresIn))
                            return
                        }
                    }
                }
                
                self.signInFail(PianoIDError.signInFailed)
            }
            
            dataTask.resume()
        }
    }
    
    private func prepareDeploymentHostUrl(host: String) -> URL? {
        var urlComponents = URLComponents(string: host)
        urlComponents?.path = deploymentHostPath
        urlComponents?.queryItems = [
            URLQueryItem(name: "aid", value: aid),
        ]
        
        return urlComponents?.url
    }
    
    private func prepareAuthorizationUrl(host: String) -> URL? {
        codeVerifier = generateCodeVerifier()
        let codeChalenge = generateCodeChallenge(codeVerifier: codeVerifier!)
        
        var urlComponents = URLComponents(string: host)
        urlComponents?.path = authorizationPath
        urlComponents?.queryItems = [
            URLQueryItem(name: "screen", value: widgetType.description),
            URLQueryItem(name: "disable_sign_up", value: "\(!signUpEnabled)"),
            URLQueryItem(name: "client_id", value: aid),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "code_challenge", value: codeChalenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "redirect_uri", value: redirectURI)
        ]
        
        var nativeOAuthProviders: [String] = []
        if useNativeGoogleSignInSDK {
            nativeOAuthProviders.append(googleOAuthProviderName)
        }
        
        if useNativeFacebookSignInSDK {
            nativeOAuthProviders.append(facebookOAuthProviderName)
        }
        
        if !nativeOAuthProviders.isEmpty {
            urlComponents?.queryItems?.append(URLQueryItem(name: "oauth_providers", value: nativeOAuthProviders.joined(separator: ",")))
        }
        
        return urlComponents?.url
    }
    
    private func prepareExchangeTokenUrl(host: String) -> URL? {
        var urlComponents = URLComponents(string: host)
        urlComponents?.path = exchangeTokenPath
        return urlComponents?.url
    }
    
    private func prepareSocialExchangeTokenUrl(host: String) -> URL? {
        var urlComponents = URLComponents(string: host)
        urlComponents?.path = socialExchangeTokenPath
        return urlComponents?.url
    }
    
    private func prepareSignOutUrl(host: String, token: String) -> URL? {
        var urlComponents = URLComponents(string: host)
        urlComponents?.path = logoutPath
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: aid),
            URLQueryItem(name: "token", value: token),
        ]
        
        return urlComponents?.url
    }
    
    @available(iOS 8, *)
    private func ios8SignIn(authUrl: URL) {
        UIApplication.shared.openURL(authUrl)
    }
    
    private func getPresentingViewController() -> UIViewController? {
        if let viewController = presentingViewController {
            return viewController
        }
        
        var topViewController: UIViewController?
        if let window = UIApplication.shared.keyWindow, let rootViewController = window.rootViewController {
            topViewController = rootViewController
            while (topViewController?.presentedViewController != nil) {
                topViewController = topViewController?.presentedViewController!
            }
        }
        
        return topViewController
    }
    
    @available(iOS 9, *)
    private func ios9SignIn(authUrl: URL) {
        let safariViewController = SFSafariViewController(url: authUrl)
        safariViewController.delegate = self
        if let viewController = getPresentingViewController() {
            viewController.present(safariViewController, animated: true, completion: nil)
            self.authSession = safariViewController
        }
    }
    
    @available(iOS 11, *)
    private func ios11SignIn(authUrl: URL) {
        let sfAuthSession = SFAuthenticationSession(url: authUrl, callbackURLScheme: redirectScheme) { (callbackUrl: URL?, error: Error?) in
            if let e = error as? SFAuthenticationError {
                self.handleError(e)
            } else if let url = callbackUrl {
                _ = self.handleUrl(url)
            } else {
                self.signInFail(.signInFailed)
            }
        }
                
        sfAuthSession.start()
        self.authSession = sfAuthSession
    }
    
    @available(iOS 12, *)
    private func ios12SignIn(authUrl: URL) {
        let webAuthSession = ASWebAuthenticationSession(url: authUrl, callbackURLScheme: redirectScheme) { (callbackUrl: URL?, error: Error?) in
            if let e = error as? ASWebAuthenticationSessionError {
                self.handleError(e)
            } else if let url = callbackUrl {
                _ = self.handleUrl(url)
            } else {
                self.signInFail(.signInFailed)
            }
        }
        
        if #available(iOS 13.0, *) {
            webAuthSession.presentationContextProvider = self
        }
                
        webAuthSession.start()
        self.authSession = webAuthSession
    }
    
    private func startAuthSession(url: URL) {
        DispatchQueue.main.async {
            if #available(iOS 9, *), self.forceSFSafariViewControllerUsage {
                self.ios9SignIn(authUrl: url)
                return
            }
            
            if #available(iOS 12, *) {
                self.ios12SignIn(authUrl: url)
            } else if #available(iOS 11, *) {
                self.ios11SignIn(authUrl: url)
            } else if #available(iOS 9, *) {
                self.ios9SignIn(authUrl: url)
            } else {
                self.ios8SignIn(authUrl: url)
            }
        }
    }
    
    private func completeAuthSession() {
        if #available(iOS 9.0, *) {
            if let safariViewController = self.authSession as? SFSafariViewController {
                DispatchQueue.main.async {
                    safariViewController.presentingViewController?.dismiss(animated: true, completion: nil)
                }
            } else if #available(iOS 11.0, *) {
                if let sfAuthSession = self.authSession as? SFAuthenticationSession {
                    DispatchQueue.main.async {
                        sfAuthSession.cancel()
                    }
                } else if #available(iOS 12.0, *) {
                    if let webAuthSession = self.authSession as? ASWebAuthenticationSession {
                        DispatchQueue.main.async {
                            webAuthSession.cancel()
                        }
                    }
                }
            }
        }
    }
    
    func googleSignIn() {
        DispatchQueue.main.async {
            if let viewController = self.getPresentingViewController() {
                GoogleSignIn.GIDSignIn.sharedInstance().presentingViewController = viewController
            }
                    
            GoogleSignIn.GIDSignIn.sharedInstance().clientID = self.googleClientId
            GoogleSignIn.GIDSignIn.sharedInstance().scopes = ["profile", "email"]
            GoogleSignIn.GIDSignIn.sharedInstance().delegate = self
            GoogleSignIn.GIDSignIn.sharedInstance().signIn()
        }
    }
    
    func facebookSignIn() {
        DispatchQueue.main.async {
            FBSDKLoginKit.LoginManager().logIn(
                permissions: [.publicProfile, .email],
                viewController: self.getPresentingViewController(),
                completion: self.facebookSignInCompleted
            )
        }
    }
    
    private func facebookSignInCompleted(result: FBSDKLoginKit.LoginResult) {
        switch result {
        case .cancelled:
            signInCancel()
        case .failed(let error):
            print("Facebook login failed with error \(error)")
            signInFail(.facebookSignInFailed)
        case .success(_, _, let token):
            handleFacebook(token: token.tokenString)
        }
    }
            
    func handleUrl(_ url: URL) -> Bool {
        guard url.absoluteString.lowercased().hasPrefix(urlSchemePrefix) else {
            return false
        }
        
        let queryParams = extractUrlQueryParams(url)
        let oauthProvider = queryParams.first(where: {$0.name == "oauth_provider"})?.value ?? "piano_id"
        guard let code = queryParams.first(where: {$0.name == "code"})?.value else {
            return false
        }
        
        authorizationCode = code
        switch oauthProvider.lowercased() {
            case googleOAuthProviderName:
                googleSignIn()
            case facebookOAuthProviderName:
                facebookSignIn()
            default:
                exchangeToken(code: code)
        }
        
        completeAuthSession()
        return true
    }
    
    @available(iOS 11.0, *)
    private func handleError(_ error: SFAuthenticationError) {
        if error.code == SFAuthenticationError.canceledLogin {
            signInCancel()
        } else {
            signInFail(.signInFailed)
        }
    }
    
    @available(iOS 12.0, *)
    private func handleError(_ error: ASWebAuthenticationSessionError) {
        if error.code == ASWebAuthenticationSessionError.canceledLogin {
            signInCancel()
        } else {
            signInFail(.signInFailed)
        }
    }
    
    private func handleGoogle(token: String) {        
        exchangeSocialToken(socialToken: token)
    }
    
    private func handleGoogleError(_ error: NSError) {
        if error.code == GIDSignInErrorCode.canceled.rawValue {
            signInCancel()
        } else {
            print("Google login failed with error \(error)")
            signInFail(.googleSignInFailed)
        }
    }
    
    private func handleFacebook(token: String) {
        exchangeSocialToken(socialToken: token)
    }
    
    private func extractUrlQueryParams(_ url: URL) -> [URLQueryItem] {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        return urlComponents?.queryItems ?? []
    }
        
    private func extractCode(url: URL) -> String? {
        if url.absoluteString.lowercased().hasPrefix(urlSchemePrefix) {
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let queryItems = urlComponents?.queryItems ?? []
            let codeItem = queryItems.first(where: { $0.name == "code"})
            if let code = codeItem?.value {
                return code
            }
        }
        
        return nil
    }
    
    private func signInCancel() {
        DispatchQueue.main.async {
            self.delegate?.pianoIDSignInDidCancel(self)
        }
    }
        
    private func signInFail(_ error: PianoIDError!) {
        DispatchQueue.main.async {
            self.delegate?.pianoID(self, didSignInForToken: nil, withError: error)
        }
    }
    
    private func signInSuccess(_ token: PianoIDToken) {
        DispatchQueue.main.async {
            self.delegate?.pianoID(self, didSignInForToken: token, withError: nil)
        }
    }
    
    private func signOutSuccess() {
        DispatchQueue.main.async {
            self.delegate?.pianoID(self, didSignOutWithError: nil)
        }
    }
    
    private func signOutFail() {
        DispatchQueue.main.async {
            self.delegate?.pianoID(self, didSignOutWithError: PianoIDError.signOutFailed)
        }
    }
    
    private func generateCodeVerifier() -> String {
        var dataBuffer = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, dataBuffer.count, &dataBuffer)
        let codeVerifier = Data(dataBuffer).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespaces)
        return codeVerifier
    }
    
    private func generateCodeChallenge(codeVerifier: String) -> String? {
        guard let data = codeVerifier.data(using: .utf8) else {
            return nil
        }
        
        var dataBuffer = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = data.withUnsafeBytes {
            CC_SHA256($0.baseAddress, CC_LONG(data.count), &dataBuffer)
        }
        let hash = Data(dataBuffer)
        let challenge = hash.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespaces)
        return challenge
    }
}

@available(iOS 9.0, *)
extension PianoID: SFSafariViewControllerDelegate {
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        signInCancel()
    }
}

@available(iOS 13.0, *)
extension PianoID: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.presentingViewController?.view.window
            ?? (self.delegate as? UIViewController)?.view.window
            ?? UIApplication.shared.keyWindow
            ?? ASPresentationAnchor()
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
