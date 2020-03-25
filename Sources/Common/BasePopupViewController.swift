import Foundation
import UIKit

@objcMembers
public class BasePopupViewController: UIViewController {
    
    fileprivate let closeButtonSize: CGFloat = 44
    
    fileprivate let closeButtonName = "piano_modal_close"
    
    fileprivate(set) internal var closeButton: UIButton!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = Bundle(for: type(of: self))
        let closeImage = UIImage(named: closeButtonName, in: bundle, compatibleWith: nil)
        closeButton = UIButton(type: .system)        
        closeButton.contentMode = UIView.ContentMode.scaleAspectFit
        closeButton.setImage(closeImage, for: UIControl.State.normal)
        closeButton.autoresizingMask = [.flexibleLeftMargin]
        closeButton.addTarget(self, action: #selector(closeButtonTouchUpInside), for: .touchUpInside)
        view.addSubview(closeButton)
    }
    
    public func show() {
        DispatchQueue.main.async {
            if let window = UIApplication.shared.keyWindow, let rootViewController = window.rootViewController {
                var topController = rootViewController
                while (topController.presentedViewController != nil) {
                    topController = topController.presentedViewController!
                }
                
                self.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                self.modalPresentationStyle = UIDevice.current.userInterfaceIdiom == .phone ? UIModalPresentationStyle.fullScreen
                                                                                            : UIModalPresentationStyle.formSheet
                topController.present(self, animated: true, completion: nil)
            }
        }
    }
    
    public func close() {
        if let vc = presentingViewController {
            vc.dismiss(animated: true, completion: nil)
        } else {
            if let window = UIApplication.shared.keyWindow, let rootViewController = window.rootViewController {
                rootViewController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        closeButton.frame = CGRect(x: view.frame.width - closeButtonSize,
                                   y: getTopMargin(),
                                   width: closeButtonSize,
                                   height: closeButtonSize)
        view.bringSubviewToFront(closeButton)
    }
    
    internal func getTopMargin() -> CGFloat {
        let modalTopMargin = view.superview?.frame.minX ?? 0
        return modalTopMargin >= UIApplication.shared.statusBarFrame.height ||
            UIApplication.shared.isStatusBarHidden ? 0 : UIApplication.shared.statusBarFrame.height
    }
    
    @objc fileprivate func closeButtonTouchUpInside(_ sender: UIButton) {
        close()
    }
}
