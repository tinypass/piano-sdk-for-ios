import UIKit
import PianoComposer
import PianoOAuth

class ViewController: UIViewController {
    
    let blueColor = UIColor(red: 56 / 255.0, green: 120 / 255.0, blue: 212 / 255.0, alpha: 1)
    var userToken: String = ""
    var userProvider: String = ""
    
    @IBOutlet weak var output: UITextView!
    @IBOutlet weak var executeButton: UIButton!
    
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
        
        initComposer()
    }
    
    override func viewDidLayoutSubviews() {
        executeButton.layer.cornerRadius = executeButton.frame.width / 2
    }
    
    func initComposer() {
        let cp = CustomParams()
        cp.content["testVar1"] = 24
        cp.content["testVar2"] = 15
        cp.user["testArray"] = ["item1", "item2", "item3"]
        
        composer = PianoComposer(aid: PianoSettings.publisherAid)
            .debug(debug: true)
            .userToken(userToken: "testUserToken")
            .delegate(delegate: self)
            .tag(tag: "tag1")
            .tag(tag: "tag2")
            .tags(tagCollection: ["tag3", "tag4"])
            .zoneId(zoneId: "Zone1")
            .customParams(customParams: cp)
            .referrer(referrer: "http://facebook.com")
            .url(url: "http://news.pubsite.com/news1")
            .customVariable(name: "customId", value: 1)
            .customVariable(name: "customArray", value: [1, 2, 3])
   
    }

    func onExecute() {        
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
        closeButton.setImage(closeImage, for: UIControlState())
        closeButton.frame = CGRect(x: vc.view.frame.width - 44, y: 10, width: 44, height: 44)
        closeButton.autoresizingMask = [.flexibleLeftMargin]
        closeButton.addTarget(self, action: #selector(closeButtonTouchUpInside), for: .touchUpInside)
        
        vc.view.addSubview(webView)
        vc.view.addSubview(closeButton)
    }
    
    func printObject(_ obj: AnyObject) -> String {
        let mirrored_object = Mirror(reflecting: obj)
        var result = "\(type(of: obj)) = {\n"
        for (_, attr) in mirrored_object.children.enumerated() {
            if let property_name = attr.label as String! {
                result.append("\t\"\(property_name)\" = \"\(attr.value)\",\n")
            }
        }
        
        result.append("}")
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
            accessInfo.append("\(printObject(user))\n")
        }
        
        if let accessList = params?.accessList {
            for item in accessList {
                accessInfo.append("\(printObject(item))\n")
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
            vc.showPopup()
        }
    }
    
    func nonSite(composer: PianoComposer, event: XpEvent) {
        output.text = output.text + "[Composer] ExpId:\(event.eventExecutionContext?.experienceId) nonSite\n"
        showPianoSite()
    }
    
    func userSegmentTrue(composer: PianoComposer, event: XpEvent) {
        output.text = output.text + "[Composer] ExpId:\(event.eventExecutionContext?.experienceId) userSegmentTrue\n"
    }
    
    func userSegmentFalse(composer: PianoComposer, event: XpEvent) {
        output.text = output.text + "[Composer] ExpId:\(event.eventExecutionContext?.experienceId) userSegmentFalse\n"
    }
    
    func meterActive(composer: PianoComposer, event: XpEvent, params: PageViewMeterEventParams?) {
        output.text = output.text + "[Composer] ExpId:\(event.eventExecutionContext?.experienceId) meterActive(name:\(params?.meterName), views:\(params?.currentViews), maxViews:\(params?.maxViews), viewsLeft:\(params?.viewsLeft)), totalViews:\(params?.totalViews))\n"
    }
    
    func meterExpired(composer: PianoComposer, event: XpEvent, params: PageViewMeterEventParams?) {
        output.text = output.text + "[Composer] ExpId:\(event.eventExecutionContext?.experienceId) meterExpired(name:\(params?.meterName), views:\(params?.currentViews), maxViews:\(params?.maxViews), viewsLeft:\(params?.viewsLeft)), totalViews:\(params?.totalViews))\n"
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

