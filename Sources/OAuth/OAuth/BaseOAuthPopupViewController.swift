import UIKit
import WebKit

@objcMembers
public class BaseOAuthPopupViewController: BasePopupViewController {

    internal let urlScheme = "iospianocomposersdk"
    internal let redirectUrlEnding = "://auth"
    
    public weak var delegate: PianoOAuthDelegate?
    public var aid = ""
    public var endpointUrl = ""
    public var widgetType: WidgetType = .login
    public var signUpEnabled = false
    
    fileprivate let indicatorSize: CGFloat = 50
    fileprivate let blueColor = UIColor(red: 56 / 255.0, green: 120 / 255.0, blue: 212 / 255.0, alpha: 1)
            
    public var webView: WKWebView!
    public var activityIndicator: UIActivityIndicatorView!
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
    }
    
    fileprivate func initViews() {
        view.backgroundColor = UIColor.white
        
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: (view.frame.width - indicatorSize) / 2,
                                                                  y: (view.frame.height - indicatorSize) / 2,
                                                                  width: indicatorSize,
                                                                  height: indicatorSize))
        activityIndicator.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin]
        activityIndicator.layer.cornerRadius = 4
        activityIndicator.backgroundColor = blueColor
        
        view.addSubview(webView)
        view.addSubview(activityIndicator)
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let topMargin = getTopMargin()
        webView.frame = CGRect(x: 0, y: topMargin, width: view.frame.width, height: view.frame.height - topMargin)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        loadOAuthForm()
    }
    
    fileprivate func loadOAuthForm() {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        
        if let url = getOAuthUrl() {
            webView.load(URLRequest(url: url))
        }
    }
    
    internal func getOAuthUrl() -> URL? {
        fatalError("getOAuthUrl has not been implemented")
    }
    
    internal func tryParseToken(url: String) {
        fatalError("tryParseToken has not been implemented")
    }
    
    internal func isOAuthUrl(url: String) -> Bool {
        fatalError("isOAuthUrl has not been implemented")
    }

    public override func close() {
        super.close()
        
        DispatchQueue.main.async {
            self.delegate?.loginCancelled()
        }
    }
    
    public func closeWithoutDelegateCallback() {
        super.close()
    }
}

extension BaseOAuthPopupViewController: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        if url.scheme == urlScheme {
            tryParseToken(url: url.description)
            decisionHandler(.cancel)
            return
        }
        
        if self.isOAuthUrl(url: url.description) {
            decisionHandler(.allow)
            return
        }
        
        if navigationAction.navigationType == .linkActivated {
            UIApplication.shared.openURL(url)
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
}

@objc public protocol PianoOAuthDelegate: class {
    
    func loginSucceeded(accessToken: String)
    
    func loginCancelled()
}
