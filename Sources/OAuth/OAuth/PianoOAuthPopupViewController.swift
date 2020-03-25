import UIKit
import WebKit

@objcMembers
public class PianoOAuthPopupViewController: BaseOAuthPopupViewController {
    
    fileprivate static let sandboxEndpointUrl = "https://sandbox.tinypass.com"
    fileprivate static let prodEndpointUrl = "https://buy.tinypass.com"
    fileprivate static let serverAction = "/checkout/user/loginShow"            
    
    public init(aid: String, endpointUrl: String) {
        super.init()
        self.aid = aid
        self.endpointUrl = endpointUrl        
    }
    
    public convenience init(aid: String) {
        self.init(aid: aid, endpointUrl: PianoOAuthPopupViewController.prodEndpointUrl)
    }
    
    public convenience init(aid: String, sandbox:Bool) {
        self.init(aid: aid, endpointUrl: sandbox
            ? PianoOAuthPopupViewController.sandboxEndpointUrl
            : PianoOAuthPopupViewController.prodEndpointUrl)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func getOAuthUrl() -> URL? {
        let redirectUri = urlScheme + redirectUrlEnding
        let requestUrl = "\(endpointUrl)\(PianoOAuthPopupViewController.serverAction)?widget=\(widgetType.description)&disable_sign_up=\(!signUpEnabled)&client_id=\(aid)&response_type=token&redirect_uri=\(redirectUri)"
        return URL(string: requestUrl)
    }
    
    internal override func isOAuthUrl(url: String) -> Bool {
        return url.range(of: "\(endpointUrl)\(PianoOAuthPopupViewController.serverAction)") != nil
    }
    
    internal override func tryParseToken(url: String) {
        var token: String?
        if let fragment = URLComponents(string: url)?.fragment {
            let params = fragment.components(separatedBy: "&")
            var dict = Dictionary<String, String>()
            for item in params {
                let keyValuePair = item.components(separatedBy: "=")
                if (keyValuePair.count == 2 && !keyValuePair[0].isEmpty) {
                    dict[keyValuePair[0]] = keyValuePair[1]
                }
            }
            
            token = dict["access_token"]
        }
        
        if let unwrappedToken = token {
            DispatchQueue.main.async {
                self.closeWithoutDelegateCallback()
                self.delegate?.loginSucceeded(accessToken: "{oauth}\(unwrappedToken)")
            }
            
        }
    }
    
}

