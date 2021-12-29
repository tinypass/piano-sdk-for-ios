import SwiftUI

import PianoOAuth
import PianoComposer

class Services {
    public static let logger: Logger = ConsoleLogger()
}

struct ContentView: View {

    @StateObject var tokenService = TokenService(logger: Services.logger)
    
    var body: some View {
        NavigationView {
            ZStack {
                if tokenService.initialized {
                    List {
                        NavigationLink("Piano ID", destination: { PianoIDView(tokenService: tokenService) })
                        NavigationLink("Composer", destination: { ComposerView(tokenService: tokenService) })
                    }
                    
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Piano")
        }
        .navigationViewStyle(.stack)
    }
}

struct PianoIDView: View {

    @ObservedObject var tokenService: TokenService

    var body: some View {
        VStack {
            if let t = tokenService.token, !t.isExpired {
                /// Token information
                if let jwt = try? decode(jwt: t.accessToken) {
                    List {
                        Section("EMAIL") {
                            Text(jwt.claim(name: "email").string ?? "Unknown")
                        }
                        Section("SUBJECT") {
                            Text(jwt.subject ?? "Unknown")
                        }
                    }
                }
                
                Button("Sign Out") {
                    /// Start sign out
                    PianoID.shared.signOut(token: t.accessToken)
                }
            } else {
                Button("Sign In") {
                    /// Start sign in
                    PianoID.shared.signIn()
                }
            }
        }
        .navigationTitle("Piano ID")
    }
}

struct ComposerView: View {

    @ObservedObject var tokenService: TokenService

    var body: some View {
        List {
            NavigationLink("User segment") { UserSegmentView(tokenService: tokenService, logger: Services.logger) }
            NavigationLink("Page view meter") { PageViewMeterView(tokenService: tokenService, logger: Services.logger) }
            NavigationLink("Show template") { ShowTemplateView(tokenService: tokenService, logger: Services.logger) }
            NavigationLink("Set response variable") { SetResponseVariableView(tokenService: tokenService, logger: Services.logger) }
        }.navigationTitle("Composer")
    }
}


