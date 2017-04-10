import UIKit
import WebKit
import PianoComposer
import PianoOAuth

class ViewController: UIViewController {
    let blueColor = UIColor(red: 56 / 255.0, green: 120 / 255.0, blue: 212 / 255.0, alpha: 1)
    var userToken: String = ""
    var userProvider: String = ""
    
    var scrollValue = Int.min
    var showTemplateParams: ShowTemplateEventParams?
    
    @IBOutlet weak var output: UITextView!
    @IBOutlet weak var executeButton: UIButton!
    var templateView: WKWebView!
    
    @IBAction func executeTouchUp(_ sender: AnyObject) {
        onExecute()
    }
    
    var composer: PianoComposer?
    
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
        
        loadPlaceholder()
        view.addSubview(templateView)
        
        initComposer()
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
        composer = PianoComposer(aid: PianoSettings.publisherAid)
            .debug(debug: true)
            .delegate(delegate: self)
            .tag(tag: "tag1")
            .tag(tag: "tag2")
            .tags(tagCollection: ["tag3", "tag4"])
            .zoneId(zoneId: "Zone1")
            .referrer(referrer: "http://facebook.com")
            .url(url: "http://news.pubsite.com/news1")
            .contentAuthor(contentAuthor: "author")
            .contentSection(contentSection: "section")
            .contentCreated(contentCreated: "")
            .contentIsNative(contentIsNative: nil)
    }

    func onExecute() {
        loadPlaceholder()
        composer?.execute()
    }
    
    func closeButtonTouchUpInside(_ sender: UIButton) {
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
        webView.loadRequest(URLRequest(url: URL(string: "http://piano.io")!))
        
        let bundle = Bundle(for: type(of: self))
        let closeImage = UIImage(named: "close", in: bundle, compatibleWith: nil)
        let closeButton = UIButton(type: .system)
        closeButton.contentMode = UIViewContentMode.scaleAspectFit
        closeButton.setImage(closeImage, for: UIControlState.normal)
        closeButton.frame = CGRect(x: vc.view.frame.width - 44, y: 10, width: 44, height: 44)
        closeButton.autoresizingMask = [.flexibleLeftMargin]
        closeButton.addTarget(self, action: #selector(closeButtonTouchUpInside), for: .touchUpInside)
        
        vc.view.addSubview(webView)
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
            if let propertyName = attr.label as String! {
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
        output.text = output.text + "[Composer] ExpId:\(event.eventExecutionContext?.experienceId) showLogin(\(params?.userProvider))\n"
        userProvider = params?.userProvider ?? ""
        if userProvider == PianoComposer.tinypassUserProviderName {
            let vc = PianoOAuthPopupViewController(aid: composer.aid, endpointUrl: composer.endpointUrl)
            vc.delegate = self
            vc.show()
        }
    }
    
    func showTemplate(composer: PianoComposer, event: XpEvent, params: ShowTemplateEventParams?) {
        output.text = output.text + "[Composer] ExpId:\(event.eventExecutionContext?.experienceId) showTemplate\n\(printObject(obj: params!))\n"
        
        if params?.delayBy?.type == DelayType.scroll {
            showTemplateParams = params
            scrollValue = params?.delayBy?.value ?? 0
        } else {
            let showTemplateController = PianoShowTemplateController(params: params!)
            showTemplateController.delegate = self
            showTemplateController.show()
        }
    }
    
    func nonSite(composer: PianoComposer, event: XpEvent) {
        output.text = output.text + "[Composer] ExpId:\(event.eventExecutionContext?.experienceId) nonSite\n"
        if let meter = event.eventExecutionContext?.activeMeters.first {
            output.text = output.text + "meter (name:\(meter.meterName), views:\(meter.views), maxViews:\(meter.maxViews), viewsLeft:\(meter.viewsLeft), totalViews:\(meter.totalViews))\n"
        }
        
        showPianoSite()
    }
    
    func userSegmentTrue(composer: PianoComposer, event: XpEvent) {
        output.text = output.text + "[Composer] ExpId:\(event.eventExecutionContext?.experienceId) userSegmentTrue\n"
    }
    
    func userSegmentFalse(composer: PianoComposer, event: XpEvent) {
        output.text = output.text + "[Composer] ExpId:\(event.eventExecutionContext?.experienceId) userSegmentFalse\n"
    }
    
    func meterActive(composer: PianoComposer, event: XpEvent, params: PageViewMeterEventParams?) {
        output.text = output.text + "[Composer] ExpId:\(event.eventExecutionContext?.experienceId) meterActive(name:\(params?.meterName), views:\(params?.views), maxViews:\(params?.maxViews), viewsLeft:\(params?.viewsLeft), totalViews:\(params?.totalViews))\n"
    }
    
    func meterExpired(composer: PianoComposer, event: XpEvent, params: PageViewMeterEventParams?) {
        output.text = output.text + "[Composer] ExpId:\(event.eventExecutionContext?.experienceId) meterExpired(name:\(params?.meterName), views:\(params?.views), maxViews:\(params?.maxViews), viewsLeft:\(params?.viewsLeft), totalViews:\(params?.totalViews))\n"
    }    
}

extension ViewController: PianoOAuthDelegate {
    // OAuth events
    func loginSucceeded(accessToken: String) {
        output.text = output.text + "[OAuth] loginSucceeded: AccessToken = \(accessToken)\n"
        userToken = accessToken
        
        output.text = output.text + "[Composer] execute with userToken\n"
        composer?.userToken(userToken: userToken)
                .execute()
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
    }
    
    func onLogin(eventData: Any) {
        output.text = output.text + "[Template onLogin]\n\(eventData)\n"
        let vc = PianoOAuthPopupViewController(aid: composer!.aid, endpointUrl: composer!.endpointUrl)
        vc.delegate = self
        vc.show()
    }
    
    func onLogout(eventData: Any) {
        output.text = output.text + "[Template onLogout]\n\(eventData)\n"
        composer!.userToken(userToken: "").execute()
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

