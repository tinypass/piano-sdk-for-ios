import UIKit
import WebKit
import Darwin
import PianoOAuth
import PianoComposer

class MainViewController: UITableViewController {

    var accessToken = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PianoID.shared.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "composer_vc") {
                navigationController?.pushViewController(vc, animated: true)
            }
        case 1:
            switch indexPath.row {
            case 0:
                let vc = PianoOAuthPopupViewController(aid: PianoSettings.AID)
                vc.delegate = self
                vc.signUpEnabled = true
                vc.widgetType = .login
                vc.show()
            case 1:
                let vc = PianoIdOAuthPopupViewController(aid: PianoSettings.AID)
                vc.delegate = self
                vc.signUpEnabled = true
                vc.widgetType = .login
                vc.show()
            case 2:
                PianoID.shared.aid = PianoSettings.AID
                PianoID.shared.signUpEnabled = true
                PianoID.shared.widgetType = .login
                PianoID.shared.signIn()
            default:
                break
            }
        case 2:
            clearStoredData()
        case 3:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "settings_vc") {
                navigationController?.pushViewController(vc, animated: true)
            }
        default:
            break
        }
    }
    
    func clearStoredData() {
        PianoComposer.clearStoredData()
        PianoID.shared.signOut(token: accessToken)
        
        URLSession.shared.reset(completionHandler: {})
        
        if #available(iOS 9.0, *) {
            let cookies = HTTPCookieStorage.shared.cookies ?? []
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
            
            WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                records.forEach { record in
                    WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                }
            }
        } 
        
        showMessage(title: "Stored data", text: "Stored data was successfully cleared")
    }
    
    func showMessage(title: String, text: String) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: UIAlertController.Style.alert)
        self.present(alert, animated: true, completion: nil)
        let duration = 2
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(duration)) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
}

extension MainViewController: PianoOAuthDelegate {
    func loginSucceeded(accessToken: String) {
        self.accessToken = accessToken
        showMessage(title: "OAuth", text: "Login succeeded\naccessToken = \(accessToken)")
    }
    
    func loginCancelled() {
        showMessage(title: "OAuth", text: "Login cancelled")
    }
}

extension MainViewController: PianoIDDelegate {
    
    func pianoID(_ pianoID: PianoID, didSignInForToken token: String!, withError error: Error!) {
        if let e = error {
            showMessage(title: "OAuth", text: "Login failed\nReason = \(e)")
        } else {
            if let token = token {
                self.accessToken = token
                showMessage(title: "OAuth", text: "Login succeeded\naccessToken = \(token)")
            }
        }
    }
    
    func pianoID(_ pianoID: PianoID, didSignOutWithToken token: String, withError error: Error!) {
        if let e = error {
            showMessage(title: "OAuth", text: "Logout with token \naccessToken = \(token) \nfailed.\nReason:\(e)")
        } else {
            showMessage(title: "OAuth", text: "Logout with token \naccessToken = \(token) \ncompleted")
        }
    }
    
    func pianoIDSignInDidCancel(_ pianoID: PianoID) {
        showMessage(title: "OAuth", text: "Login cancelled")
    }
}
