import Foundation

internal class RequestParamBuilder: NSObject {
    
    fileprivate var params = Dictionary<String, String>()
    
    @discardableResult internal func add(name:String, value: String) -> RequestParamBuilder {
        params[name] = value
        return self
    }
    
    internal func build() -> String {
        var result = ""
        var first = true
        
        for key in params.keys {
            guard let value = params[key], !value.isEmpty else {
                continue
            }
            
            if first {
                first = false
                result.append("\(key)=\(escape(str: "\(value)"))")
            } else {
                result.append("&\(key)=\(escape(str: "\(value)"))")
            }
        }
        
        return result
    }
    
    fileprivate func escape(str: String) -> String {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: generalDelimitersToEncode + subDelimitersToEncode)
        
        return str.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? ""
    }
}
