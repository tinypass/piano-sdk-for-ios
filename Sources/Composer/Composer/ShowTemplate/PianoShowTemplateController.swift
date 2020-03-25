import Foundation
import UIKit
import WebKit

@objcMembers
public class PianoShowTemplateController: NSObject {
    
    public weak var delegate: PianoShowTemplateDelegate?
    public var params: ShowTemplateEventParams
    public var showTemplatePopupViewController: PianoShowTemplatePopupViewController?
    
    public init(params: ShowTemplateEventParams) {
        self.params = params
    }
    
    public func show() {
        let delayValue = params.delayBy?.value ?? 0
        let delayType = params.delayBy?.type ?? .time
        
        switch delayType {
        case .scroll:
            self.showByDisplayMode()
            return
        case .time:
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delayValue)) {
                self.showByDisplayMode()
            }
        }
    }
    
    public func reloadWithToken(userToken: String) {
        switch params.displayMode {
        case .inline:
            guard let view = delegate?.findViewBySelector(selector: params.containerSelector) else {
                return
            }
            
            if view is WKWebView {
                let wkWebView = (view as! WKWebView)
                wkWebView.evaluateJavaScript("piano.reloadTemplateWithUserToken('\(userToken)')")
            }            
        case .modal:
            showTemplatePopupViewController?.reloadWithToken(userToken: userToken)
        }
    }
    
    fileprivate func showByDisplayMode() {
        switch params.displayMode {
        case .inline:
            showInline()
        case .modal:
            showModal()
        }
    }
    
    fileprivate func showModal() {
        showTemplatePopupViewController = PianoShowTemplatePopupViewController(params: params)
        showTemplatePopupViewController?.delegate = delegate
        showTemplatePopupViewController?.show()
    }
    
    fileprivate func showInline() {
        guard let view = delegate?.findViewBySelector(selector: params.containerSelector) else {
            return
        }
        
        if view is WKWebView {
            guard let url = URL(string: params.templateUrl) else {
                return
            }
            
            let request = URLRequest(url: url)
            let wkWebView = (view as! WKWebView)
            let userContentController = wkWebView.configuration.userContentController
            userContentController.removeScriptMessageHandler(forName: JSMessageHandlerType.close.description)
            userContentController.removeScriptMessageHandler(forName: JSMessageHandlerType.closeAndRefresh.description)
            userContentController.removeScriptMessageHandler(forName: JSMessageHandlerType.register.description)
            userContentController.removeScriptMessageHandler(forName: JSMessageHandlerType.login.description)
            userContentController.removeScriptMessageHandler(forName: JSMessageHandlerType.logout.description)
            userContentController.removeScriptMessageHandler(forName: JSMessageHandlerType.customEvent.description)
            userContentController.add(self, name: JSMessageHandlerType.close.description)
            userContentController.add(self, name: JSMessageHandlerType.closeAndRefresh.description)
            userContentController.add(self, name: JSMessageHandlerType.register.description)
            userContentController.add(self, name: JSMessageHandlerType.login.description)
            userContentController.add(self, name: JSMessageHandlerType.logout.description)
            userContentController.add(self, name: JSMessageHandlerType.customEvent.description)
            wkWebView.load(request)
        }
    }
}

extension PianoShowTemplateController: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let handlerType = JSMessageHandlerType.fromString(value: message.name)
        DispatchQueue.main.async {
            switch handlerType {
            case .close:
                ExternalEventService.sharedInstance.logExternalEvent(endpointUrl: self.params.endpointUrl, trackingId: self.params.trackingId, eventType: "EXTERNAL_EVENT", eventGroupId: "close", customParams: "{}")
                self.delegate?.onClose?(eventData: message.body)
            case .closeAndRefresh:
                self.delegate?.onCloseAndRefresh?(eventData: message.body)
            case .register:
                self.delegate?.onRegister?(eventData: message.body)
            case .login:
                self.delegate?.onLogin?(eventData: message.body)
            case .logout:
                self.delegate?.onLogout?(eventData: message.body)
            case .customEvent:
                self.delegate?.onCustomEvent?(eventData: message.body)
            case .unknown:
                break
            }
        }
    }
}
