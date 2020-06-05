import UIKit
import WebKit
import Darwin
import PianoOAuth
import PianoComposer

class MainViewController: UITableViewController {

    var accessToken = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            PianoID.shared.delegate = self
            PianoID.shared.googleClientId = "971267624263-dfmmc53ifbd23ajjjgfmo2m41diosopn.apps.googleusercontent.com"
            PianoID.shared.aid = PianoSettings.AID
            PianoID.shared.signUpEnabled = true
            PianoID.shared.widgetType = .login
            PianoID.shared.signIn()
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

extension MainViewController: PianoIDDelegate {
    
    func pianoID(_ pianoID: PianoID, didSignInForToken token: PianoIDToken!, withError error: Error!) {
        if let e = error {
            showMessage(title: "OAuth", text: "Login failed\nReason = \(e)")
        } else {
            if let token = token {
                self.accessToken = token.accessToken
                showMessage(title: "OAuth", text: "Login succeeded\naccessToken = \(token.accessToken)")
            }
        }
    }
    
    func pianoID(_ pianoID: PianoID, didSignOutWithError error: Error!) {
       if let e = error {
               showMessage(title: "OAuth", text: "Logout failed.\nReason:\(e)")
           } else {
               showMessage(title: "OAuth", text: "Logout completed")
           }
    }        
    
    func pianoIDSignInDidCancel(_ pianoID: PianoID) {
        showMessage(title: "OAuth", text: "Login cancelled")
    }
}
