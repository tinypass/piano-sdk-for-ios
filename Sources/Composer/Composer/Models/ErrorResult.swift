import Foundation

internal class ErrorResult: NSObject {
    
    fileprivate(set) internal var errors: Array<ServerError>
    
    internal init(array: [Any]) {
        errors = Array<ServerError>()
        
        for item in array {
            if let errorDict = item as? [String: Any] {
                errors.append(ServerError(dict: errorDict))
            }
        }
    }

}
