import Foundation
import WebKit

@objcMembers
public class PianoShowTemplatePopupViewController: BasePopupViewController {
    
    fileprivate let indicatorSize: CGFloat = 50
    fileprivate let blueColor = UIColor(red: 56 / 255.0, green: 120 / 255.0, blue: 212 / 255.0, alpha: 1)
    
    public var webView: WKWebView!
    public var activityIndicator: UIActivityIndicatorView!
    
    public var showTemplateParams: ShowTemplateEventParams
    public weak var delegate: PianoShowTemplateDelegate?
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(params: ShowTemplateEventParams) {
        self.showTemplateParams = params
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
        loadTemplate()
    }
    
    fileprivate func initViews() {
        closeButton.isHidden = !showTemplateParams.showCloseButton
        view.backgroundColor = UIColor.white
        
        let controller = WKUserContentController()
        controller.add(self, name: JSMessageHandlerType.close.description)
        controller.add(self, name: JSMessageHandlerType.closeAndRefresh.description)
        controller.add(self, name: JSMessageHandlerType.register.description)
        controller.add(self, name: JSMessageHandlerType.login.description)
        controller.add(self, name: JSMessageHandlerType.logout.description)
        controller.add(self, name: JSMessageHandlerType.customEvent.description)
        
        let conf = WKWebViewConfiguration()
        conf.userContentController = controller
        
        webView = WKWebView(frame: .zero, configuration: conf)
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
    
    public override func viewWillAppear(_ animated: Bool) {
    }
    
    public override func viewDidAppear(_ animated: Bool) {
    }
    
    public override func close() {
        super.close()
        DispatchQueue.main.async {
            self.delegate?.onClose?(eventData: NSNull())
        }
        
        ExternalEventService.sharedInstance.logExternalEvent(endpointUrl: showTemplateParams.endpointUrl, trackingId: showTemplateParams.trackingId, eventType: "EXTERNAL_EVENT", eventGroupId: "close", customParams: "{}")
    }
    
    public func reloadWithToken(userToken: String) {
        webView.evaluateJavaScript("piano.reloadTemplateWithUserToken('\(userToken)')")
    }
    
    fileprivate func closeWithoutDelegateCallback() {
        super.close()
    }
    
    fileprivate func loadTemplate() {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        
        if let url = URL(string: showTemplateParams.templateUrl) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}

extension PianoShowTemplatePopupViewController: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        if url.description.range(of: showTemplateParams.templateUrl) != nil {
            decisionHandler(.allow)
            return
        }
        
        if navigationAction.navigationType == .linkActivated {
            UIApplication.shared.openURL(url)
        }
        
        decisionHandler(.cancel)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
}

extension PianoShowTemplatePopupViewController: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {                
        let handlerType = JSMessageHandlerType.fromString(value: message.name)
        DispatchQueue.main.async {
            switch handlerType {
            case .close:
                ExternalEventService.sharedInstance.logExternalEvent(endpointUrl: self.showTemplateParams.endpointUrl, trackingId: self.showTemplateParams.trackingId, eventType: "EXTERNAL_EVENT", eventGroupId: "close", customParams: "{}")
                self.closeWithoutDelegateCallback()
                self.delegate?.onClose?(eventData: message.body)
            case .closeAndRefresh:
                self.closeWithoutDelegateCallback()
                self.delegate?.onCloseAndRefresh?(eventData: message.body)
            case .register:
                self.delegate?.onRegister?(eventData: message.body)
            case .login:
                self.delegate?.onLogin?(eventData: message.body)
            case .logout:
                self.delegate?.onLogout?(eventData: message.body)
            case .customEvent:
                self.delegate?.onCustomEvent?(eventData: message.body)
            case .unknown:
                break
            }
        }
    }
}

