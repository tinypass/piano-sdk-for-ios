import Foundation
import UIKit

class SettingsViewController : UITableViewController {
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch indexPath.section {
            case 0:
                cell.textLabel?.text = PianoSettings.AID
                break
            default:
                break
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
            case 0:
                showAlert(title : PianoSettings.AID, section: indexPath.section)
                break
            default:
                break
        }
    }
    
    func showAlert(title : String, section : Int) {
        let alert = UIAlertController(title: "Edit Settings", message: "Please edit value", preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "settings.alertView"
        
        alert.addTextField(configurationHandler: { (newTitle) -> Void in
            newTitle.text = title
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        })
        
        let okayAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
            
            switch section {
                case 0:
                    PianoSettings.AID = (alert.textFields?.first?.text)!
                    break                
                default:
                    break
            }
            
            self.tableView.reloadData()
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        })
        
        alert.addAction(okayAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
