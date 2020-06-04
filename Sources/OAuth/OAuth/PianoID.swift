import AuthenticationServices
import CommonCrypto
import UIKit
import SafariServices

@objcMembers
public class PianoID: NSObject {
    
    public static let shared: PianoID = PianoID()

    public weak var delegate: PianoIDDelegate?
    internal weak var authViewController: PianoIDOAuthViewController?
        
    private let sandbox = "https://sandbox.piano.io"
    private let idProd = "https://id.piano.io"
    private let apiProd = "https://buy.piano.io"
                
    private let deploymentHostPath = "/api/v3/anon/mobile/sdk/id/deployment/host"
    private let authorizationPath = "/id/api/v1/identity/vxauth/authorize"
    private let tokenPath = "/id/api/v1/identity/oauth/token"
    private let logoutPath = "/id/api/v1/identity/logout"
    
    private var urlSession: URLSession
            
    public var aid: String = ""
    public var isSandbox = false
    public var endpointUrl: String = ""
    public var signUpEnabled = false
    public var widgetType: WidgetType = .login    
    public var presentingViewController: UIViewController?
    
    public var googleClientId: String = ""
    internal var nativeSignInWithAppleEnabled = false
    
    private let urlSchemePrefix = "io.piano.id"
    private let urlSchemePath = "success"
    
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
        if endpointUrl.isEmpty {
            return isSandbox ? sandbox : idProd
        } else {
            return endpointUrl
        }
    }
    
    private var apiHost: String {
        if endpointUrl.isEmpty {
            return isSandbox ? sandbox : apiProd
        } else {
            return endpointUrl
        }
    }
    
    fileprivate var _currentToken: PianoIDToken?
    public var currentToken: PianoIDToken? {
        if _currentToken == nil {
            _currentToken = PianoIDTokenStorage.shared.loadToken(aid: getAID())
        }
        return _currentToken
    }
    
    private override init() {
        let config = URLSessionConfiguration.default
        config.httpCookieStorage = nil
        config.httpCookieAcceptPolicy = .never
        urlSession = URLSession(configuration: config)
        super.init()
    }
    
    internal func getAID() -> String {        
        assert(!aid.isEmpty, "PIANO_ID: Piano AID should be specified")
        return aid
    }
    
    public func signIn() {
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
    
    public func refreshToken(_ refreshToken: String, completion: @escaping(PianoIDToken?, PianoIDError?) -> Void) {
        if let url = prepareRefreshTokenUrl(host: idHost) {
            let body: [String: Any] = [
                "client_id": getAID(),
                "grant_type": "refresh_token",
                "refresh_token": refreshToken
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
                            let expiresIn = responseObject["expires_in"] as? Int64 {
                            
                            completion(PianoIDToken(accessToken: accessToken, refreshToken: refreshToken, expiresIn: expiresIn), nil)
                            return
                        }
                    }
                }
                                
                completion(nil, PianoIDError.refreshFailed)
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
              
    private func prepareDeploymentHostUrl(host: String) -> URL? {
        var urlComponents = URLComponents(string: host)
        urlComponents?.path = deploymentHostPath
        urlComponents?.queryItems = [
            URLQueryItem(name: "aid", value: getAID()),
        ]
        
        return urlComponents?.url
    }
    
    private func prepareAuthorizationUrl(host: String) -> URL? {
        guard var urlComponents = URLComponents(string: host) else {
            return nil
        }
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "client_id", value: getAID()),
            URLQueryItem(name: "screen", value: widgetType.description),
            URLQueryItem(name: "disable_sign_up", value: "\(!signUpEnabled)"),
            URLQueryItem(name: "response_type", value: "token")
        ]
        
        var nativeOAuthProviders: [String] = []
        nativeOAuthProviders.append(SocialOAuthProvider.google.description)
        nativeOAuthProviders.append(SocialOAuthProvider.facebook.description)

        if nativeSignInWithAppleEnabled {
            nativeOAuthProviders.append(SocialOAuthProvider.apple.description)
        }
        
        if !nativeOAuthProviders.isEmpty {
            queryItems.append(URLQueryItem(name: "oauth_providers", value: nativeOAuthProviders.joined(separator: ",")))
        }
        
        urlComponents.path = authorizationPath
        urlComponents.queryItems = queryItems
        return urlComponents.url
    }
        
    private func prepareRefreshTokenUrl(host: String) -> URL? {
        guard var urlComponents = URLComponents(string: host) else {
            return nil
        }
        
        urlComponents.path = tokenPath
        return urlComponents.url
    }
    
    private func prepareSignOutUrl(host: String, token: String) -> URL? {
        guard var urlComponents = URLComponents(string: host) else {
            return nil
        }
        
        urlComponents.path = logoutPath
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: getAID()),
            URLQueryItem(name: "token", value: token),
        ]
        
        return urlComponents.url
    }
    
    private func startAuthSession(url: URL) {
        if self.authViewController != nil {
            return
        }
        
        DispatchQueue.main.async {
            if let presentingViewController = self.getPresentingViewController() {
                let authViewController = PianoIDOAuthViewController(title: "", url: url)
                presentingViewController.present(authViewController, animated: true, completion: nil)
                self.authViewController = authViewController
            }
        }
    }
    
    internal func getPresentingViewController() -> UIViewController? {
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
    
    internal func handleUrl(_ url: URL) -> Bool {
        guard url.absoluteString.lowercased().hasPrefix(urlSchemePrefix) else {
            return false
        }
        
        if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), let queryParams = urlComponents.queryItems {
            if let accessToken = queryParams.first(where: {$0.name == "access_token"})?.value,
                let refreshToken = queryParams.first(where: {$0.name == "refresh_token"})?.value,
                let expiresIn = Int64(queryParams.first(where: {$0.name == "expires_in"})?.value ?? "") {
             
                let token = PianoIDToken(accessToken: accessToken, refreshToken: refreshToken, expiresIn: expiresIn)
                signInSuccess(token)
                return true
            }
        }
                
        return false
    }
        
    internal func signInSuccess(_ token: PianoIDToken) {
        _currentToken = token
        _ = PianoIDTokenStorage.shared.saveToken(token, aid: getAID())
        DispatchQueue.main.async {
            self.delegate?.pianoID(self, didSignInForToken: token, withError: nil)
        }
    }
    
    internal func signInFail(_ error: PianoIDError!) {
        DispatchQueue.main.async {
            self.delegate?.pianoID(self, didSignInForToken: nil, withError: error)
        }
    }        
    
    internal func signInCancel() {
        DispatchQueue.main.async {
            self.delegate?.pianoIDSignInDidCancel(self)
        }
    }
    
    internal func signOutSuccess() {
        DispatchQueue.main.async {
            self.delegate?.pianoID(self, didSignOutWithError: nil)
        }
    }
    
    internal func signOutFail() {
        DispatchQueue.main.async {
            self.delegate?.pianoID(self, didSignOutWithError: PianoIDError.signOutFailed)
        }
    }
        
    internal func logError(_ message: String) {
        print("PianoID: \(message)")
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

