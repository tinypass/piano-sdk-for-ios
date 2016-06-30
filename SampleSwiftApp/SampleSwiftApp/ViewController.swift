import UIKit
import PianoComposer
import PianoOAuth

class ViewController: UIViewController {
    let aid = "AID"
    
    let blueColor = UIColor(red: 56 / 255.0, green: 120 / 255.0, blue: 212 / 255.0, alpha: 1)
    var userToken: String = ""
    var userProvider: String = ""
    
    @IBOutlet weak var output: UITextView!
    @IBOutlet weak var executeButton: UIButton!
    
    @IBAction func executeTouchUp(sender: AnyObject) {
        onExecute()
    }
    
    var composer: PianoComposer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        executeButton.layer.cornerRadius = executeButton.frame.width / 2
        executeButton.layer.borderWidth = 3
        executeButton.layer.borderColor = blueColor.CGColor
        
        output.layer.cornerRadius = 3
        output.layer.borderWidth = 1
        output.layer.borderColor = blueColor.CGColor
        
        initComposer()
    }
    
    func initComposer() {
        let cp = CustomParams()
        cp.content["testVar1"] = 24
        cp.content["testVar2"] = 15
        cp.user["testArray"] = ["item1", "item2", "item3"]
        
        composer = PianoComposer(aid: aid)
            .debug(true)
            .userToken("testUserToken")
            .userProvider("testUserProvider")
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
        
        let webView = UIWebView(frame: CGRectMake(0, 40, vc.view.frame.width, vc.view.frame.height - 40))
        webView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        webView.loadRequest(NSURLRequest(URL: NSURL(string: "http://piano.io")!))
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let closeImage = UIImage(named: "close", inBundle: bundle, compatibleWithTraitCollection: nil)
        let closeButton = UIButton(type: .System)
        closeButton.contentMode = UIViewContentMode.ScaleAspectFit
        closeButton.setImage(closeImage, forState: .Normal)
        closeButton.frame = CGRectMake(vc.view.frame.width - 44, 10, 44, 44)
        closeButton.autoresizingMask = [.FlexibleLeftMargin]
        closeButton.addTarget(self, action: #selector(closeButtonTouchUpInside), forControlEvents: .TouchUpInside)
        
        vc.view.addSubview(webView)
        vc.view.addSubview(closeButton)
    }
}

extension ViewController: PianoComposerDelegate {
    func composerExecutionCompleted(composer: PianoComposer) {
        output.text = output.text + "[Composer] executionCompleted\n"
    }
    
    // Experience events
    func experienceExecute(composer: PianoComposer, event: XpEvent, params: ExperienceExecuteEventParams?) {
        output.text = output.text + "[Composer] ExpId:\(event.eventExecutionContext?.experienceId) experienceExecute(\(params?.user?.uid), \(params?.user?.email), (\(params?.accessList.description))) \n"
    }
    
    func showLogin(composer: PianoComposer, event: XpEvent, params: ShowLoginEventParams?) {
        output.text = output.text + "[Composer] ExpId:\(event.eventExecutionContext?.experienceId) showLogin(\(params?.userProvider))\n"
        userProvider = params?.userProvider ?? ""
        if userProvider == "tinypass_accounts" {
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
        composer?.userToken(userToken)
                .userProvider(userProvider)
                .execute()
    }
    
    func loginCancelled() {
        output.text = output.text + "[OAuth] loginCancelled\n"
    }
}

