import SwiftUI

import PianoComposer

fileprivate class SetResponseVariableService: ComposerService {

    @Published var variables: [String:Any]? = nil

    override func prepare(composer: PianoComposer) {
        variables = nil
        _ = composer.tag("srv")
    }

    func setResponseVariable(composer: PianoComposer, event: XpEvent, params: SetResponseVariableParams?) {
        if let v = params?.variables {
            variables = v
        }
    }
}

struct SetResponseVariableView: View {

    @ObservedObject private var service: SetResponseVariableService

    init(tokenService: TokenService, logger: Logger) {
        service = SetResponseVariableService(tokenService: tokenService, logger: logger)
    }

    var body: some View {
        VStack(spacing: 20) {
            if !service.loading {
                Button("Execute") {
                    service.execute(withToken: false)
                }

                if let v = service.variables {
                    List {
                        Section("BOOL") {
                            Text(boolValue("bool", v))
                        }
                        Section("INTEGER") {
                            Text(intValue("int", v))
                        }
                        Section("STRING") {
                            Text(stringValue("string", v))
                        }
                    }.listStyle(GroupedListStyle())
                }
            } else {
                ProgressView()
            }
        }.navigationTitle("Set response variable")
    }

    func boolValue(_ name: String, _ vars: [String:Any]) -> String {
        if let v = vars[name] as? Bool {
            return v ? "true" : "false"
        }
        return "-"
    }

    func intValue(_ name: String, _ vars: [String:Any]) -> String {
        if let v = vars[name] as? Int {
            return "\(v)"
        }
        return "-"
    }

    func stringValue(_ name: String, _ vars: [String:Any]) -> String {
        if let v = vars[name] as? String {
            return v
        }
        return "-"
    }
}