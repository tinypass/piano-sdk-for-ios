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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {        
        switch indexPath.section {
        case 0:
            if let vc = storyboard?.instantiateViewControllerWithIdentifier("composer_vc") {
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
    
    func showMessage(title: String, text: String) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: UIAlertControllerStyle.Alert)
        self.presentViewController(alert, animated: true, completion: nil)
        let duration: Int64 = 2
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (duration * Int64(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
