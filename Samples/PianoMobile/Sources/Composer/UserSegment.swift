import SwiftUI

import PianoComposer

fileprivate class UserSegmentService: ComposerService {

    @Published private(set) var auth: Bool? = nil

    override func prepare(composer: PianoComposer) {
        auth = nil
        _ = composer.tag("user_segment")
    }

    func userSegmentTrue(composer: PianoComposer, event: XpEvent) {
        auth = true
    }

    func userSegmentFalse(composer: PianoComposer, event: XpEvent) {
        auth = false
    }
}

struct UserSegmentView: View {

    @ObservedObject private var service: UserSegmentService

    init(tokenService: TokenService, logger: Logger) {
        service = UserSegmentService(tokenService: tokenService, logger: logger)
    }

    var body: some View {
        VStack(spacing: 20) {
            if !service.loading {
                Button("Execute") {
                    service.execute(withToken: false)
                }

                if service.tokenService.token != nil {
                    Button("Execute with token") {
                        service.execute(withToken: true)
                    }
                }

                if let a = service.auth {
                    Text("User segment: \(a ? "true" : "false")")
                }
            } else {
                ProgressView()
            }
        }.navigationTitle("User segment")
    }
}