import UIKit
import WebKit
import PianoComposer
import PianoOAuth

class ViewController: UIViewController {
    let blueColor = UIColor(red: 56 / 255.0, green: 120 / 255.0, blue: 212 / 255.0, alpha: 1)
    var userToken: String = ""
    
    var composer: PianoComposer?
    
    var pianoIdMainAid: String!
    var pianoIdMainEndpoint: String!
    var pianoIdMainDelegate: PianoIDDelegate?
    
    var scrollValue = Int.min
    var showTemplateParams: ShowTemplateEventParams?
    var showTemplateViewController: PianoShowTemplateController?
    var templateView: WKWebView!
    
    @IBOutlet weak var output: UITextView!
    @IBOutlet weak var executeButton: UIButton!
    
    @IBAction func executeTouchUp(_ sender: AnyObject) {
        onExecute()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        executeButton.layer.borderWidth = 3
        executeButton.layer.borderColor = blueColor.cgColor
        
        output.layer.cornerRadius = 3
        output.layer.borderWidth = 1
        output.layer.borderColor = blueColor.cgColor
        output.delegate = self
        output.contentSize = CGSize(width: 0, height: 10000)
        
        templateView = WKWebView(frame: .zero)
        templateView.layer.cornerRadius = 3
        templateView.layer.borderWidth = 1
        templateView.layer.borderColor = blueColor.cgColor
        templateView.navigationDelegate = self
        templateView.accessibilityIdentifier = "experienceView.templateView"
        
        view.addSubview(templateView)
        loadPlaceholder()
        
        initComposer()
    }
    
    deinit {
        PianoID.shared.aid = pianoIdMainAid
        PianoID.shared.endpointUrl = pianoIdMainEndpoint
        PianoID.shared.delegate = pianoIdMainDelegate
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        executeButton.layer.cornerRadius = executeButton.frame.width / 2
        templateView.frame = CGRect(x: output.frame.minX,
                                    y: output.frame.maxY + 5,
                                    width: output.frame.width,
                                    height: view.frame.height - output.frame.maxY - 10)
    }
    
    func loadPlaceholder() {
        let placeholder = "<body><div style=\"color: grey; font-size: 40px; right: 50%; bottom: 50%; transform: translate(50%,50%); position: absolute;\">Template container</div></body>"
        templateView.loadHTMLString(placeholder, baseURL: nil)
    }
    
    func initComposer() {
        let cp = CustomParams()
            .content(key: "testVar1",value: "24")
            .content(key: "testVar2", value: "15")
            .user(key: "testUserVar", value: "text")
            .request(key:"testRequesVar", value: "request")
    
        composer = PianoComposer(aid: PianoSettings.AID)
            .debug(true)
            .delegate(self)
            .tag("tag1")
            .tag("tag2")
            .tags(["tag3", "tag4"])
            .zoneId("Zone1")
            .customParams(cp)
            .referrer("http://facebook.com")
            .url("http://news.pubsite.com/news1")
            .customVariable(name: "customId", value: "1")
            .contentAuthor("author")
            .contentSection("section")
            .contentCreated("")
            .contentIsNative(nil)
        
        pianoIdMainAid = PianoID.shared.aid
        PianoID.shared.aid = composer!.aid
        
        pianoIdMainEndpoint = PianoID.shared.endpointUrl
        PianoID.shared.endpointUrl = composer!.endpointUrl
        
        pianoIdMainDelegate = PianoID.shared.delegate
        PianoID.shared.delegate = self
    }

    func onExecute() {
        loadPlaceholder()
        composer?.userToken(userToken)
            .execute()
    }
    
    @objc func closeButtonTouchUpInside(_ sender: UIButton) {
        if let vc = parent {
            vc.dismiss(animated: true, completion: nil)
        } else {
            let window = UIApplication.shared.keyWindow
            if let rootViewController = window?.rootViewController {
                rootViewController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func showPianoSite() {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.white
        self.present(vc, animated: true) {}
        
        let webView = UIWebView(frame: CGRect(x: 0, y: 40, width: vc.view.frame.width, height: vc.view.frame.height - 40))
        webView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        vc.view.addSubview(webView)
        webView.loadRequest(URLRequest(url: URL(string: "http://piano.io")!))
        
        let bundle = Bundle(for: type(of: self))
        let closeImage = UIImage(named: "close", in: bundle, compatibleWith: nil)
        let closeButton = UIButton(type: .system)
        closeButton.contentMode = UIView.ContentMode.scaleAspectFit
        closeButton.setImage(closeImage, for: UIControl.State.normal)
        closeButton.frame = CGRect(x: vc.view.frame.width - 44, y: UIApplication.shared.statusBarFrame.height, width: 44, height: 44)
        closeButton.autoresizingMask = [.flexibleLeftMargin]
        closeButton.addTarget(self, action: #selector(closeButtonTouchUpInside), for: .touchUpInside)
        vc.view.addSubview(closeButton)
    }
    
    func printObject(obj: Any?, indentVal: String = "") -> String {
        guard obj != nil else {
            return ""
        }
        
        let defaultIndent = "    "
        var indent = indentVal
        
        let mirroredObject = Mirror(reflecting: obj!)
        var result = "\(type(of: obj!)) {\n"
        let prevIndent = indent
        indent += defaultIndent
        for (index, attr) in mirroredObject.children.enumerated() {
            if let propertyName = attr.label as String? {
                let separator = index == mirroredObject.children.count - 1 ? "" : ","
                let mirroredProperty = Mirror(reflecting: attr.value)
                if mirroredProperty.children.count == 0 {
                    result.append("\(indent)\"\(propertyName)\" = \"\(attr.value)\"\(separator)\n")
                } else {
                    result.append("\(indent)\"\(propertyName)\" = \(printObject(obj: attr.value, indentVal: indent))\(separator)\n")
                }
            }
        }
        
        result.append("\(prevIndent)}")
        return result
    }
}

extension ViewController: PianoComposerDelegate {
    func composerExecutionCompleted(composer: PianoComposer) {
        output.text = output.text + "[Composer] executionCompleted\n"
    }
    
    func composerExecutionErrors(composer: PianoComposer, errors: Array<ServerError>) {
        output.text = output.text + "[Composer] executionFailed\n"
        for e in errors {
            output.text = output.text + printObject(obj: e)
        }
    }
    
    // Experience events
    func experienceExecute(composer: PianoComposer, event: XpEvent, params: ExperienceExecuteEventParams?) {
        output.text = output.text + "[Composer] experienceExecute\n"
        output.text = output.text + printObject(obj: params) + "\n"
    }
    
    func experienceExecutionFailed(composer: PianoComposer, event: XpEvent, params: FailureEventParams?) {
        output.text = output.text + "[Composer] experienceExecutionFailure\n"
        output.text = output.text + printObject(obj: params) + "\n"
    }
    
    func showLogin(composer: PianoComposer, event: XpEvent, params: ShowLoginEventParams?) {
        output.text = output.text + "[Composer] ExpId:\(event.eventExecutionContext?.experienceId ?? "n/a") showLogin(\(params?.userProvider ?? "n/a"))\n"
        let userProvider = params?.userProvider ?? ""
        
        if userProvider == PianoComposer.pianoIdUserProviderName {
            PianoID.shared.signIn()
        }
    }
    
    func showTemplate(composer: PianoComposer, event: XpEvent, params: ShowTemplateEventParams?) {
        output.text = output.text + "[Composer] ExpId:\(event.eventExecutionContext?.experienceId ?? "n/a") showTemplate\n\(printObject(obj: params!))\n"
        
        if params?.delayBy?.type == DelayType.scroll {
            showTemplateParams = params
            scrollValue = params?.delayBy?.value ?? 0
        } else {
            showTemplateViewController = PianoShowTemplateController(params: params!)
            showTemplateViewController?.delegate = self
            showTemplateViewController?.show()
        }
    }
    
    func nonSite(composer: PianoComposer, event: XpEvent) {
        output.text = output.text + "[Composer] ExpId:\(event.eventExecutionContext?.experienceId ?? "n/a") nonSite\n"
        if let meter = event.eventExecutionContext?.activeMeters.first {
            output.text = output.text + "meter (name:\(meter.meterName), views:\(meter.views), maxViews:\(meter.maxViews), viewsLeft:\(meter.viewsLeft), totalViews:\(meter.totalViews))\n"
        }
        
        showPianoSite()
    }
    
    func userSegmentTrue(composer: PianoComposer, event: XpEvent) {
        output.text = output.text + "[Composer] ExpId:\(event.eventExecutionContext?.experienceId ?? "n/a") userSegmentTrue\n"
    }
    
    func userSegmentFalse(composer: PianoComposer, event: XpEvent) {
        output.text = output.text + "[Composer] ExpId:\(event.eventExecutionContext?.experienceId ?? "n/a") userSegmentFalse\n"
    }
    
    func meterActive(composer: PianoComposer, event: XpEvent, params: PageViewMeterEventParams?) {
        output.text = output.text + "[Composer] ExpId:\(event.eventExecutionContext?.experienceId ?? "n/a") meterActive(name:\(params?.meterName ?? "n/a"), views:\(params?.views ?? 0), maxViews:\(params?.maxViews ?? 0), viewsLeft:\(params?.viewsLeft ?? 0), totalViews:\(params?.totalViews ?? 0))\n"
    }
    
    func meterExpired(composer: PianoComposer, event: XpEvent, params: PageViewMeterEventParams?) {
        output.text = output.text + "[Composer] ExpId:\(event.eventExecutionContext?.experienceId ?? "n/a") meterExpired(name:\(params?.meterName ?? "n/a"), views:\(params?.views ?? 0), maxViews:\(params?.maxViews ?? 0), viewsLeft:\(params?.viewsLeft ?? 0), totalViews:\(params?.totalViews ?? 0))\n"
    }    
}

extension ViewController: PianoOAuthDelegate {
    // OAuth events
    func loginSucceeded(accessToken: String) {
        output.text = output.text + "[OAuth] loginSucceeded: AccessToken = \(accessToken)\n"
        userToken = accessToken
        showTemplateViewController?.reloadWithToken(userToken: userToken)
    }
    
    func loginCancelled() {
        output.text = output.text + "[OAuth] loginCancelled\n"
    }
}

extension ViewController: PianoShowTemplateDelegate {
    
    // Show template events
    func findViewBySelector(selector: String) -> UIView? {        
        return templateView
    }
    
    func onClose(eventData: Any) {
        output.text = output.text + "[Template onClose]\n\(eventData)\n"
    }
    
    func onCloseAndRefresh(eventData: Any) {
        output.text = output.text + "[Template onCloseAndRefresh]\n\(eventData)\n"
    }
    
    func onRegister(eventData: Any) {
        output.text = output.text + "[Template onRegister]\n\(eventData)\n"
        let vc = PianoOAuthPopupViewController(aid: composer!.aid, endpointUrl: composer!.endpointUrl)
        vc.signUpEnabled = true
        vc.widgetType = WidgetType.register
        vc.delegate = self
        vc.show()
    }
    
    func onLogin(eventData: Any) {
        output.text = output.text + "[Template onLogin]\n\(eventData)\n"
        PianoID.shared.signIn()
    }
    
    func onLogout(eventData: Any) {
        output.text = output.text + "[Template onLogout]\n\(eventData)\n"
    }
    
    func onCustomEvent(eventData: Any) {
        output.text = output.text + "[Template onCustomEvent]\n\(eventData)\n"
    }
}

extension ViewController: UITextViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.showTemplateParams != nil && self.scrollValue != Int.min && (scrollView.contentOffset.y >= CGFloat(self.scrollValue)) {
            let showTemplateController = PianoShowTemplateController(params: self.showTemplateParams!)
            showTemplateController.delegate = self
            showTemplateController.show()
            self.scrollValue = Int.min            
        }
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if navigationAction.request.url?.description.range(of: "/checkout/template/show") != nil {
            decisionHandler(.allow)
            return
        }
        
        if let url = navigationAction.request.url, navigationAction.navigationType == .linkActivated {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            } else {                
            }
        }
        
        decisionHandler(.allow)
    }
}

extension ViewController: PianoIDDelegate {
    
    func pianoID(_ pianoID: PianoID, didSignOutWithError error: Error!) {
    }
    
    func pianoIDSignInDidCancel(_ pianoID: PianoID) {
    }
    
    func pianoID(_ pianoID: PianoID, didSignInForToken token: PianoIDToken!, withError error: Error!) {
        loginSucceeded(accessToken: token.accessToken)
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
