import PianoComposer

class ComposerService: ObservableObject, PianoComposerDelegate {

    let tokenService: TokenService
    let logger: Logger

    @Published private(set) var loading = false

    init(tokenService: TokenService, logger: Logger) {
        self.tokenService = tokenService
        self.logger = logger
    }
    
    func execute(withToken: Bool = true) {
        tokenService.request { token in
            let composer = PianoComposer(aid: Settings.aid, endpoint: Settings.endpoint)
                    .debug(true)
                    .delegate(self)
                    .url("https://piano.io/sdk/sample")

            if withToken, let t = token {
                /// Set token if available
                _ = composer.userToken(t.accessToken)
            }

            self.prepare(composer: composer)

            self.loading = true

            composer.execute()
        }
    }

    func composerExecutionCompleted(composer: PianoComposer) {
        loading = false
        logger.debug("Composer execution completed")
    }

    func experienceExecutionFailed(composer: PianoComposer, event: XpEvent, params: FailureEventParams?) {
        logger.error(params?.errorMessage ?? "Experience execution failed")
    }

    open func prepare(composer: PianoComposer) {}
}
