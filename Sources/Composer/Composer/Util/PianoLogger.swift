import Foundation

internal class PianoLogger: NSObject {
    
    internal static let defaultInstance: PianoLogger = PianoLogger()
    
    internal var logLevel: LogLevel = .off
    
    fileprivate func log(level: LogLevel, message: String, fileName: String, funcName: String, lineNumber: Int) {
        if  self.logLevel <= level {
            print("\(Date()) [\(level)] \(message)")
        }
    }
    
    internal static func getLogger() -> PianoLogger {
        return defaultInstance
    }
    
    internal static func debug(message: String, fileName: String = #file, funcName: String = #function, lineNumber: Int = #line) {
        defaultInstance.log(level: .debug, message: message, fileName: fileName, funcName: funcName, lineNumber: lineNumber)
    }
    
    internal func debug(message: String, fileName: String = #file, funcName: String = #function, lineNumber: Int = #line) {
        self.log(level: .debug, message: message, fileName: fileName, funcName: funcName, lineNumber: lineNumber)
    }
    
    internal static func info(message: String, fileName: String = #file, funcName: String = #function, lineNumber: Int = #line) {
        defaultInstance.log(level: .info, message: message, fileName: fileName, funcName: funcName, lineNumber: lineNumber)
    }
    
    internal func info(message: String, fileName: String = #file, funcName: String = #function, lineNumber: Int = #line) {
        self.log(level: .info, message: message, fileName: fileName, funcName: funcName, lineNumber: lineNumber)
    }
    
    internal static func error(message: String, fileName: String = #file, funcName: String = #function, lineNumber: Int = #line) {
        defaultInstance.log(level: .error, message: message, fileName: fileName, funcName: funcName, lineNumber: lineNumber)
    }
    
    internal func error(message: String, fileName: String = #file, funcName: String = #function, lineNumber: Int = #line) {
        self.log(level: .error, message: message, fileName: fileName, funcName: funcName, lineNumber: lineNumber)
    }
}

@objc internal enum LogLevel: Int {
    case all = 0
    case debug = 1
    case info = 2
    case error = 3
    case off = 4
}

extension LogLevel: Comparable {
    static internal func < (lhs:LogLevel, rhs:LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

extension LogLevel: CustomStringConvertible {
    public var description: String {
        switch self {
            case .all:
                return "all"
            case .debug:
                return "debug"
            case .info:
                return "info"
            case .error:
                return "error"
            case .off:
                return "off"
        }
    }
}

