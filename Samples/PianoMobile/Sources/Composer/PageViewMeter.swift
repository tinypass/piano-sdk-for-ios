import SwiftUI

import PianoComposer

fileprivate class PageViewMeterService: ComposerService {

    @Published private(set) var active: Bool? = nil

    override func prepare(composer: PianoComposer) {
        _ = composer.tag("pvm")
    }

    func meterActive(composer: PianoComposer, event: XpEvent, params: PageViewMeterEventParams?) {
        active = true
    }

    func meterExpired(composer: PianoComposer, event: XpEvent, params: PageViewMeterEventParams?) {
        active = false
    }
}

struct PageViewMeterView: View {

    @ObservedObject private var service: PageViewMeterService

    init(tokenService: TokenService, logger: Logger) {
        service = PageViewMeterService(tokenService: tokenService, logger: logger)
    }

    var body: some View {
        VStack(spacing: 20) {
            if !service.loading {
                Button("Execute") {
                    service.execute()
                }

                if let a = service.active {
                    Text("Meter active: \(a ? "true" : "false")")
                }
            } else {
                ProgressView()
            }
        }.navigationTitle("Page view meter")
    }
}