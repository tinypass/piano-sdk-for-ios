import UIKit
import Darwin
import PianoOAuth

class MainViewController: UITableViewController, PianoOAuthDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        switch (indexPath as NSIndexPath).section {
        case 0:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "composer_vc") {
                navigationController?.pushViewController(vc, animated: true)
            }
        case 1:
            let vc = PianoOAuthPopupViewController(aid: PianoSettings.publisherAid, sandbox: true)
            vc.delegate = self
            vc.showPopup()
        default:
            break
        }
    }
    
    func loginSucceeded(accessToken: String) {
        showMessage("OAuth", text: "Login succeeded\naccessToken = \(accessToken)")
    }
    
    func loginCancelled() {
        showMessage("OAuth", text: "Login cancelled")
    }
    
    func showMessage(_ title: String, text: String) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: UIAlertControllerStyle.alert)
        let duration = 2
        
        self.present(alert, animated: true, completion: nil)        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(duration)) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
}
