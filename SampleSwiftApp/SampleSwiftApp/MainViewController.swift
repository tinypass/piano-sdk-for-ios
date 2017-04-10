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
        switch indexPath.section {
        case 0:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "composer_vc") {
                navigationController?.pushViewController(vc, animated: true)
            }
        case 1:
            let vc = PianoOAuthPopupViewController(aid: PianoSettings.publisherAid)
            vc.delegate = self
            vc.signUpEnabled = false
            vc.widgetType = indexPath.row == 0 ? .login : .register
            vc.show()
        default:
            break
        }
    }
    
    func loginSucceeded(accessToken: String) {
        showMessage(title: "OAuth", text: "Login succeeded\naccessToken = \(accessToken)")
    }
    
    func loginCancelled() {
        showMessage(title: "OAuth", text: "Login cancelled")
    }
    
    func showMessage(title: String, text: String) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: UIAlertControllerStyle.alert)
        self.present(alert, animated: true, completion: nil)
        let duration = 2
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(duration)) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
}
