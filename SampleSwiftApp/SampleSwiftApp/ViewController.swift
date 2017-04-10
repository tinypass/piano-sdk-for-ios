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
    
    @IBAction func executeTouchUp(sender: AnyObject) {
        onExecute()
    }
    
    var composer: PianoComposer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        executeButton.layer.borderWidth = 3
        executeButton.layer.borderColor = blueColor.CGColor
        
        output.layer.cornerRadius = 3
        output.layer.borderWidth = 1
        output.layer.borderColor = blueColor.CGColor
        
        templateView = WKWebView(frame: .zero)
        templateView.layer.cornerRadius = 3
        templateView.layer.borderWidth = 1
        templateView.layer.borderColor = blueColor.CGColor
        
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
        let cp = CustomParams()
        cp.content["testVar1"] = 24
        cp.content["testVar2"] = 15
        cp.user["testArray"] = ["item1", "item2", "item3"]
        
        composer = PianoComposer(aid: PianoSettings.publisherAid)
            .debug(true)
            .userToken("testUserToken")
            .delegate(self)
            .tag("tag1")
            .tag("tag2")
            .tags(["tag3", "tag4"])
            .zoneId("Zone1")
            .customParams(cp)
            .referrer("http://facebook.com")
            .url("http://news.pubsite.com/news1")
            .customVariable("customId", value: 1)
            .customVariable("customArray", value: [1, 2, 3])
    }

    func onExecute() {        
        composer?.execute()
    }
    
    func closeButtonTouchUpInside(sender: UIButton) {
        if let vc = parentViewController {
            vc.dismissViewControllerAnimated(true, completion: nil)
        } else {
            let window = UIApplication.sharedApplication().keyWindow
            if let rootViewController = window?.rootViewController {
                rootViewController.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    func showPianoSite() {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.whiteColor()
        self.presentViewController(vc, animated: true) {}
        
        let webView = UIWebView(frame: CGRect(x: 0, y: 40, width: vc.view.frame.width, height: vc.view.frame.height - 40))
        webView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        webView.loadRequest(NSURLRequest(URL: NSURL(string: "http://piano.io")!))
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let closeImage = UIImage(named: "close", inBundle: bundle, compatibleWithTraitCollection: nil)
        let closeButton = UIButton(type: .System)
        closeButton.contentMode = UIViewContentMode.ScaleAspectFit
        closeButton.setImage(closeImage, forState: UIControlState.Normal)
        closeButton.frame = CGRect(x: vc.view.frame.width - 44, y: 10, width: 44, height: 44)
        closeButton.autoresizingMask = [.FlexibleLeftMargin]
        closeButton.addTarget(self, action: #selector(closeButtonTouchUpInside), forControlEvents: .TouchUpInside)
        
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
        var result = "\(obj!.dynamicType) {\n"
        let prevIndent = indent
        indent += defaultIndent
        for (index,  attr) in mirroredObject.children.enumerate() {
            if let propertyName = attr.label as String! {
                let separator = index == mirroredObject.children.count - 1 ? "" : ","
                let mirroredProperty = Mirror(reflecting: attr.value)
                if mirroredProperty.children.count == 0 {
                    result.appendContentsOf("\(indent)\"\(propertyName)\" = \"\(attr.value)\"\(separator)\n")
                } else {
                    result.appendContentsOf("\(indent)\"\(propertyName)\" = \(printObject(attr.value, indentVal: indent))\(separator)\n")
                }
            }
        }
        
        result.appendContentsOf("\(prevIndent)}")
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
        var accessInfo = ""
        if let user = params?.user {
            accessInfo.appendContentsOf("\(printObject(user))\n")
        }
        
        if let accessList = params?.accessList {
            for item in accessList {
                accessInfo.appendContentsOf("\(printObject(item))\n")
            }
        }
        
        output.text = output.text + accessInfo;
    }

    func showLogin(composer: PianoComposer, event: XpEvent, params: ShowLoginEventParams?) {
        output.text = output.text + "[Composer] ExpId:\(event.eventExecutionContext?.experienceId) showLogin(\(params?.userProvider))\n"
        userProvider = params?.userProvider ?? ""
        if userProvider == PianoComposer.tinypassUserProviderName {
            let vc = PianoOAuthPopupViewController(aid: composer.aid)
            vc.delegate = self
            vc.show()
        }
    }
    
    func showTemplate(composer: PianoComposer, event: XpEvent, params: ShowTemplateEventParams?) {
        output.text = output.text + "[Composer] ExpId:\(event.eventExecutionContext?.experienceId) showTemplate\n\(printObject(params!))\n"
        
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
        composer?.userToken(userToken)
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
    
    func onClose(eventData: AnyObject) {
        output.text = output.text + "[Template onClose]\n\(eventData)\n"
    }
    
    func onCloseAndRefresh(eventData: AnyObject) {
        output.text = output.text + "[Template onCloseAndRefresh]\n\(eventData)\n"
    }
    
    func onRegister(eventData: AnyObject) {
        output.text = output.text + "[Template onRegister]\n\(eventData)\n"
    }
    
    func onLogin(eventData: AnyObject) {
        output.text = output.text + "[Template onLogin]\n\(eventData)\n"
        let vc = PianoOAuthPopupViewController(aid: composer!.aid, endpointUrl: composer!.endpointUrl)
        vc.delegate = self
        vc.show()
    }
    
    func onLogout(eventData: AnyObject) {
        output.text = output.text + "[Template onLogout]\n\(eventData)\n"
        composer!.userToken("").execute()
    }
    
    func onCustomEvent(eventData: AnyObject) {
        output.text = output.text + "[Template onCustomEvent]\n\(eventData)\n"
    }
}


extension ViewController: UITextViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.showTemplateParams != nil && self.scrollValue != Int.min && (scrollView.contentOffset.y >= CGFloat(self.scrollValue)) {
            let showTemplateController = PianoShowTemplateController(params: self.showTemplateParams!)
            showTemplateController.delegate = self
            showTemplateController.show()
            self.scrollValue = Int.min
        }
    }
}

