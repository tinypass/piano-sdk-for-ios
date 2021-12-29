import PianoOAuth

class TokenService: ObservableObject, PianoIDDelegate {

    private let logger: Logger

    @Published private(set) var initialized = false
    @Published private(set) var token: PianoIDToken?

    init(logger: Logger) {
        self.logger = logger

        /// Set Piano ID settings
        PianoID.shared.endpointUrl = Settings.endpoint.api
        PianoID.shared.aid = Settings.aid
        PianoID.shared.delegate = self

        token = PianoID.shared.currentToken
        request { _ in
            DispatchQueue.main.async {
                self.initialized = true
            }
        }
    }

    func request(completion: @escaping (PianoIDToken?) -> Void) {
        if let t = token {
            if t.isExpired {
                /// Refresh token if expired
                PianoID.shared.refreshToken(t.refreshToken) { token, error in
                    if let t = token {
                        self.token = t
                        completion(t)
                        return
                    }

                    self.logger.error(error, or: "Invalid result")
                    completion(nil)
                }
            } else {
                completion(t)
            }
            return
        }

        completion(nil)
    }

    /// Sign In callback
    func signIn(result: PianoIDSignInResult!, withError error: Error!) {
        if let r = result {
            token = r.token
        } else {
            logger.error(error, or: "Invalid result")
        }
    }

    /// Sign Out callback
    func signOut(withError error: Error!) {
        logger.error(error, or: "Invalid result")
        token = nil
    }

    /// Cancel callback
    func cancel() {
    }
}
