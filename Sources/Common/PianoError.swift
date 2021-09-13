import Foundation

/// Piano common error
public class PianoError: NSObject, LocalizedError
{
    /// Error message
    @objc public let message: String

    /// Create instance of PianoError
    ///
    /// - Parameters:
    ///   - message: Error message
    @objc public init(_ message: String) {
        self.message = message
    }

    /// Error description
    @objc public var errorDescription: String? { message }
}
