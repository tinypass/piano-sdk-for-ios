import Foundation

protocol Logger {
    func debug(_ message: String)
    func error(_ message: String)
    func error(_ error: Error?, or: String)
}

class ConsoleLogger: Logger {
    func debug(_ message: String) {
        print("[DEBUG] \(message)")
    }

    func error(_ message: String) {
        print("[ERROR] \(message)")
    }

    func error(_ error: Error?, or: String) {
        print("[ERROR] \(error?.localizedDescription ?? or)")
    }
}
