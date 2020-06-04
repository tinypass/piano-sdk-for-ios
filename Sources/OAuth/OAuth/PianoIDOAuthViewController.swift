import UIKit
import WebKit

@objcMembers
class PianoIDOAuthViewController: UIViewController {

    let loginSuccessMessageHandler = "loginSuccess"
    let socialLoginMessageHandler = "socialLogin"
                        
    weak var mainWebView: WKWebView?
    weak var secondaryWebView: WKWebView?
    
    let webViewContentController = WKUserContentController()
    let estimatedProgressPropertyKeyPath = "estimatedProgress"
    let canGoBackPropertyKeyPath = "canGoBack"
    let canGoForwardPropertyKeyPath = "canGoForward"
    
    var url: URL?
    var code: String = ""
    
    var navigationBar: UINavigationBar!
    var progressView: UIProgressView!
    
    var toolbar: UIToolbar!
    var backButton: UIBarButtonItem!
    var forwardButton: UIBarButtonItem!        
    
    init(title: String?, url: URL?) {
        super.init(nibName: nil, bundle: nil)
        
        self.url = url
        self.title = title     
    }
    
    required init?(coder: NSCoder) {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isBeingDismissed {
            deinitWebViews()
        }
    }
    
    fileprivate func initViews() {
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        
        initNavigationItem()
        initNavigationBar()
        initToolbar()
        initWebView()
        setViewsConstraints()
        
        load()
    }
    
    fileprivate func initNavigationItem() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onCancelButtonTouch(_:)))
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(onRefreshButtonTouch(_:)))
        navigationItem.setLeftBarButton(cancelButton, animated: false)
        navigationItem.setRightBarButton(refreshButton, animated: false)
    }
    
    fileprivate func initNavigationBar() {
        progressView = UIProgressView(progressViewStyle: .bar)
        progressView.isHidden = true
        
        navigationBar = UINavigationBar()
        navigationBar.sizeToFit()
        view.addSubview(navigationBar)
        
        navigationBar.setItems([navigationItem], animated: false)
        navigationBar.addSubview(progressView)
        navigationBar.isTranslucent = false
    }
    
    fileprivate func initToolbar() {
        toolbar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: view.bounds.width, height: 0.0)))
        toolbar.sizeToFit()
        view.addSubview(toolbar)
        
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 60.0
        
        if let chevronLeftImage = UIImage(named: "piano_chevron"), let chevronLeftCGImage = chevronLeftImage.cgImage {
            backButton = UIBarButtonItem(image: chevronLeftImage, style: .plain, target: self, action: #selector(onBackButtonTouch(_:)))
            forwardButton = UIBarButtonItem(image: UIImage(cgImage: chevronLeftCGImage, scale: chevronLeftImage.scale, orientation: .upMirrored), style: .plain, target: self, action: #selector(onForwardButtonTouch(_:)))
        } else {
            backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(onBackButtonTouch(_:)))
            forwardButton = UIBarButtonItem(title: "Forward", style: .plain, target: self, action: #selector(onForwardButtonTouch(_:)))
        }
        
        backButton.isEnabled = false
        forwardButton.isEnabled = false
        toolbar.setItems([backButton, fixedSpace, forwardButton], animated: false)
    }
    
    fileprivate func initWebView() {
        webViewContentController.add(self, name: loginSuccessMessageHandler)
        webViewContentController.add(self, name: socialLoginMessageHandler)
        
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = false
        config.userContentController = webViewContentController
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.addObserver(self, forKeyPath: estimatedProgressPropertyKeyPath, options: .new, context: nil)
        webView.addObserver(self, forKeyPath: canGoBackPropertyKeyPath, options: .new, context: nil)
        webView.addObserver(self, forKeyPath: canGoForwardPropertyKeyPath, options: .new, context: nil)
        
        let jsBridgeInitialScript =
            "window.PianoIDMobileSDK={};" +
            "window.PianoIDMobileSDK.\(loginSuccessMessageHandler)=" +
            "function(body){try{webkit.messageHandlers.\(loginSuccessMessageHandler).postMessage(body)}catch(err){console.log(err)}};" +
            "window.PianoIDMobileSDK.\(socialLoginMessageHandler)=" +
            "function(body){try{webkit.messageHandlers.\(socialLoginMessageHandler).postMessage(body)}catch(err){console.log(err)}};"
        webView.evaluateJavaScript(jsBridgeInitialScript)
        view.addSubview(webView)
        mainWebView = webView
    }
    
    fileprivate func deinitWebViews() {
        webViewContentController.removeScriptMessageHandler(forName: loginSuccessMessageHandler)
        webViewContentController.removeScriptMessageHandler(forName: socialLoginMessageHandler)
        
        if let webView = mainWebView {
            deinitWebView(webView)
            mainWebView = nil
        }
        
        if let webView = secondaryWebView {
            deinitWebView(webView)
            secondaryWebView = nil
        }
    }
    
    fileprivate func deinitWebView(_ webView: WKWebView) {
        webView.stopLoading()
        webView.removeFromSuperview()
        webView.uiDelegate = nil
        webView.navigationDelegate = nil
        webView.removeObserver(self, forKeyPath: estimatedProgressPropertyKeyPath)
        webView.removeObserver(self, forKeyPath: canGoBackPropertyKeyPath)
        webView.removeObserver(self, forKeyPath: canGoForwardPropertyKeyPath)
    }
    
    fileprivate func setViewsConstraints() {
        if #available(iOS 9.0, *) {
            var topAnchor = view.topAnchor
            var bottomAnchor = view.bottomAnchor
            
            if #available(iOS 11.0, *) {
                topAnchor = view.safeAreaLayoutGuide.topAnchor
                bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor
            }
            
            navigationBar.translatesAutoresizingMaskIntoConstraints = false
            navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            navigationBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            navigationBar.topAnchor.constraint(equalTo: topAnchor).isActive = true
            
            progressView.translatesAutoresizingMaskIntoConstraints = false
            progressView.leftAnchor.constraint(equalTo: navigationBar.leftAnchor).isActive = true
            progressView.rightAnchor.constraint(equalTo: navigationBar.rightAnchor).isActive = true
            progressView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor).isActive = true
            
            toolbar.translatesAutoresizingMaskIntoConstraints = false
            toolbar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            toolbar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            toolbar.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            
            if let mainWebView = mainWebView {
                mainWebView.translatesAutoresizingMaskIntoConstraints = false
                mainWebView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
                mainWebView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
                mainWebView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 1.0).isActive = true
                mainWebView.bottomAnchor.constraint(equalTo: toolbar.topAnchor, constant: -1.0).isActive = true
            }
        } else {
            navigationBar.translatesAutoresizingMaskIntoConstraints = true
            navigationBar.autoresizingMask = [.flexibleWidth]
            navigationBar.frame = CGRect(
                origin: .zero,
                size: CGSize(width: view.bounds.width, height: navigationBar.bounds.height)
            )
            
            progressView.translatesAutoresizingMaskIntoConstraints = true
            progressView.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
            progressView.frame = CGRect(
                origin: CGPoint(x: 0, y: navigationBar.bounds.height - progressView.bounds.height),
                size: CGSize(width: view.bounds.width, height: progressView.bounds.height)
            )
            
            toolbar.translatesAutoresizingMaskIntoConstraints = true
            toolbar.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
            toolbar.frame = CGRect(x: 0, y: view.bounds.height - toolbar.bounds.height, width: view.bounds.width, height: toolbar.bounds.height)
            
            if let mainWebView = mainWebView {
                mainWebView.translatesAutoresizingMaskIntoConstraints = true
                mainWebView.autoresizingMask = [.flexibleTopMargin, .flexibleWidth, .flexibleHeight]
                mainWebView.frame = CGRect(
                    origin: CGPoint(x: 0, y: navigationBar.bounds.height),
                    size: CGSize(width: view.bounds.width, height: view.bounds.height - navigationBar.bounds.height - toolbar.bounds.height)
                )
            }
        }
    }
    
    func load() {
        if let url = self.url {
            mainWebView?.load(URLRequest(url: url))
        }
    }
    
    func socialSignInCallback(aid: String, oauthProvider: String, socialToken: String, params: [String: Any] = [:]) {
        let body: [String: Any] = [
            "clientId": aid,
            "oauthProvider": oauthProvider,
            "socialToken": socialToken,
            "code": code,
            "params": params
        ]
        
        let jsonBody = JSONSerializationUtil.serializeObjectToJSONString(object: body)
        let script = "window.PianoIDMobileSDK.socialLoginCallback('\(jsonBody)');"
        mainWebView?.evaluateJavaScript(script, completionHandler:  nil)
    }
    
    @objc
    func onCancelButtonTouch(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: {
            PianoID.shared.signInCancel()
        })
    }
    
    @objc
    func onRefreshButtonTouch(_ sender: UIBarButtonItem) {
        let activeWebView = secondaryWebView ?? mainWebView
        activeWebView?.reload()
    }
    
    @objc
    func onBackButtonTouch(_ sender: UIBarButtonItem) {
        if let activeWebView = secondaryWebView {
            if activeWebView.canGoBack {
                activeWebView.goBack()
            } else {
                secondaryWebView = nil
                webViewDidClose(activeWebView)
            }
        } else if let activeWebView = mainWebView, activeWebView.canGoBack {
            activeWebView.goBack()
        }
    }
    
    @objc
    func onForwardButtonTouch(_ sender: UIBarButtonItem) {
        if let activeWebView = secondaryWebView ?? mainWebView, activeWebView.canGoForward {
            activeWebView.goForward()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == estimatedProgressPropertyKeyPath, let webView = object as? WKWebView {
            progressView.setProgress(Float(webView.estimatedProgress), animated: true);
        }
        
        if (keyPath == canGoBackPropertyKeyPath || keyPath == canGoForwardPropertyKeyPath) {
            updateNavigationButtons()
        }
    }
    
    fileprivate func updateNavigationButtons() {
        backButton.isEnabled = (secondaryWebView != nil) || (secondaryWebView == nil && (mainWebView?.canGoBack ?? false))
        forwardButton.isEnabled = (secondaryWebView?.canGoForward ?? false) || ((secondaryWebView == nil) && mainWebView?.canGoForward ?? false)
    }
}

extension PianoIDOAuthViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        updateNavigationButtons()
        progressView.setProgress(0.0, animated: false)
        progressView.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.setProgress(1.0, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.progressView.isHidden = true
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        progressView.setProgress(1.0, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.progressView.isHidden = true
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressView.setProgress(1.0, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.progressView.isHidden = true
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
}

extension PianoIDOAuthViewController: WKUIDelegate {
            
    func webViewDidClose(_ webView: WKWebView) {
        if webView == secondaryWebView {
            secondaryWebView = nil
        }
        
        deinitWebView(webView)
        updateNavigationButtons()
        progressView.setProgress(0.0, animated: false)
        progressView.isHidden = false
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard webView == mainWebView else {
            return nil
        }
        
        let nextWebView = WKWebView(frame: .zero, configuration: configuration)
        nextWebView.navigationDelegate = self
        nextWebView.uiDelegate = self
        nextWebView.addObserver(self, forKeyPath: estimatedProgressPropertyKeyPath, options: .new, context: nil);
        nextWebView.addObserver(self, forKeyPath: canGoBackPropertyKeyPath, options: .new, context: nil)
        nextWebView.addObserver(self, forKeyPath: canGoForwardPropertyKeyPath, options: .new, context: nil)
        
        view.addSubview(nextWebView)
        view.bringSubviewToFront(nextWebView)
        view.bringSubviewToFront(navigationBar)
        view.bringSubviewToFront(toolbar)
        setWebViewConstraints(nextWebView)
        secondaryWebView = nextWebView
        
        updateNavigationButtons()
        return nextWebView
    }
    
    fileprivate func setWebViewConstraints(_ webView: WKWebView) {
        guard let mainWebView = mainWebView else {
            return
        }
        
        if #available(iOS 9.0, *) {
            webView.translatesAutoresizingMaskIntoConstraints = false
            webView.leftAnchor.constraint(equalTo: mainWebView.leftAnchor).isActive = true
            webView.rightAnchor.constraint(equalTo: mainWebView.rightAnchor).isActive = true
            webView.topAnchor.constraint(equalTo: mainWebView.topAnchor).isActive = true
            webView.bottomAnchor.constraint(equalTo: mainWebView.bottomAnchor).isActive = true
        } else {
            webView.translatesAutoresizingMaskIntoConstraints = true
            webView.frame = mainWebView.frame
            webView.autoresizingMask = [.flexibleTopMargin, .flexibleWidth, .flexibleHeight]
        }
    }
}

extension PianoIDOAuthViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case loginSuccessMessageHandler:
            loginSuccess(body: message.body as? String ?? "")
        case socialLoginMessageHandler:
            socialLogin(body: message.body as? String ?? "")
        default:
            logError("Unknown JS message handler: \"\(message.name)\"")
        }
    }
    
    func loginSuccess(body: String) {
        guard let json = body.parseJson() else {
            logError("Login success: incorrect input parameters")
            return
        }
                
        if let accessToken = json["accessToken"] as? String, let expiresIn = json["expiresIn"]as? Int64 {
            let refreshToken = json["refreshToken"] as? String ?? ""
            let idToken = PianoIDToken(accessToken: accessToken, refreshToken: refreshToken, expiresIn: expiresIn)
            presentingViewController?.dismiss(animated: true, completion: {
                PianoID.shared.signInSuccess(idToken)
            })
        }
    }
    
    func socialLogin(body: String) {
        guard let json = body.parseJson(), let oauthProvider = json["oauthProvider"] as? String, let code = json["code"] as? String else {
            logError("Social login: incorrect input parameters")
            return
        }
        
        self.code = code
                 
        switch oauthProvider.lowercased() {
        case SocialOAuthProvider.google.description:
            PianoID.shared.googleSignIn()
        case SocialOAuthProvider.facebook.description:
            PianoID.shared.facebookSignIn()
        case SocialOAuthProvider.apple.description:
            if #available(iOS 13.0, *) {
                PianoID.shared.appleSignIn()
            } else {
                logError("Apple Sign In not supported for current iOS version")
            }
        default:
            logError("Unknown OAuth provider: \"\(oauthProvider)\"")
        }
    }
    
    func logError(_ message: String) {
        print("PianoID: \(message)")
    }
}

