import UIKit

@objcMembers
@available(*, deprecated, message: "Will be deleted in next releases. Use PianoID instead")
public class PianoIdOAuthPopupViewController: BaseOAuthPopupViewController {

    fileprivate static let sandboxEndpointUrl = "https://sandbox.tinypass.com"
    fileprivate static let prodEndpointUrl = "https://id.tinypass.com"
    fileprivate static let serverAction = "/id/api/v1/identity/vxauth/authorize"
    
    public init(aid: String, endpointUrl: String) {
        super.init()
        self.aid = aid
        self.endpointUrl = endpointUrl
    }
    
    public convenience init(aid: String) {
        self.init(aid: aid, endpointUrl: PianoIdOAuthPopupViewController.prodEndpointUrl)
    }
    
    public convenience init(aid: String, sandbox:Bool) {
        self.init(aid: aid, endpointUrl: sandbox
            ? PianoIdOAuthPopupViewController.sandboxEndpointUrl
            : PianoIdOAuthPopupViewController.prodEndpointUrl)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func getOAuthUrl() -> URL? {
        let redirectUri = urlScheme + redirectUrlEnding
        let requestUrl = "\(endpointUrl)\(PianoIdOAuthPopupViewController.serverAction)?screen=\(widgetType.description)&disable_sign_up=\(!signUpEnabled)&client_id=\(aid)&response_type=token&force_redirect=1&redirect_uri=\(redirectUri)"
        return URL(string: requestUrl)
    }
    
    internal override func isOAuthUrl(url: String) -> Bool {
        return url.range(of: "\(endpointUrl)\(PianoIdOAuthPopupViewController.serverAction)") != nil
    }
    
    internal override func tryParseToken(url: String) {
        var token: String?
        if let query = URLComponents(string: url)?.query {
            let params = query.components(separatedBy: "&")
            var dict = Dictionary<String, String>()
            for item in params {
                let keyValuePair = item.components(separatedBy: "=")
                if (keyValuePair.count == 2 && !keyValuePair[0].isEmpty) {
                    dict[keyValuePair[0]] = keyValuePair[1]
                }
            }
            
            token = dict["token"]
        }
        
        if let unwrappedToken = token {
            DispatchQueue.main.async {
                self.closeWithoutDelegateCallback()
                self.delegate?.loginSucceeded(accessToken: unwrappedToken)
            }            
        }
    }
        
}
