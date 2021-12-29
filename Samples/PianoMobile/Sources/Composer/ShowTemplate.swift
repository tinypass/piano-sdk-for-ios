import SwiftUI
import WebKit

import PianoComposer

struct WebView : UIViewRepresentable {

    let webView: WKWebView

    @Binding var height: CGFloat

    class Coordinator: NSObject, WKNavigationDelegate {

        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { (height, error) in
                DispatchQueue.main.async {
                    self.parent.height = height as! CGFloat
                }
            })
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        webView.scrollView.bounces = false
        webView.navigationDelegate = context.coordinator

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

fileprivate class ShowTemplateService: ComposerService, PianoShowTemplateDelegate {

    @Published var webView: WKWebView? = nil

    override func prepare(composer: PianoComposer) {
        webView = nil
        _ = composer.tag("templates")
    }

    func showTemplate(composer: PianoComposer, event: XpEvent, params: ShowTemplateEventParams?) {
        if let p = params {
            if p.displayMode == .inline {
                webView = WKWebView()
            }

            let controller = PianoShowTemplateController(params: p)
            controller.delegate = self
            controller.show()
        }
    }

    func findViewBySelector(selector: String) -> UIView? {
        selector == "template" ? webView : nil
    }
}

struct ShowTemplateView: View {

    @ObservedObject private var service: ShowTemplateService

    @State private var height: CGFloat = .zero

    init(tokenService: TokenService, logger: Logger) {
        service = ShowTemplateService(tokenService: tokenService, logger: logger)
    }

    var body: some View {
        VStack(spacing: 20) {
            if !service.loading {
                Button("Execute") {
                    service.execute()
                }

                if let wv = service.webView {
                    WebView(webView: wv, height: $height)
                        .frame(height: height > 320 ? 320 : height)
                }
            } else {
                ProgressView()
            }
        }.navigationTitle("Show template")
    }
}