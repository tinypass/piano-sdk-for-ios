import Foundation

internal class JSONSerializationUtil {

    internal static func deserializeResponse(response: URLResponse, responseData: Data) -> [String: Any]? {
        let readingOptions = JSONSerialization.ReadingOptions(rawValue: 0)
        var stringEncoding = String.Encoding.utf8
        
        if let textEncodingName = response.textEncodingName , !textEncodingName.isEmpty {
            let encoding = CFStringConvertIANACharSetNameToEncoding(textEncodingName as CFString)
            if encoding != kCFStringEncodingInvalidId {
                stringEncoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(encoding))
            }
        }
        
        var responseObject: Any? = nil
        let responseString:String = String(data: responseData, encoding: stringEncoding) ?? ""
        
        if let data = responseString.data(using: String.Encoding.utf8) , data.count > 0 {
            responseObject = try? JSONSerialization.jsonObject(with: data, options: readingOptions)                
        }
        
        return responseObject as? [String: Any]
    }
    
    internal static func serializeObjectToJSONData(object: Any?) -> Data {
        if object == nil {
            return Data()
        }
        
        do {
            if JSONSerialization.isValidJSONObject(object!) {
                let jsonData = try JSONSerialization.data(withJSONObject: object!)
                return jsonData
            }
        } catch {
        }

        return Data()
    }
    
    internal static func serializeObjectToJSONString(object: Any?) -> String {
        let jsonData = serializeObjectToJSONData(object: object)
        return String(data: jsonData, encoding: String.Encoding.utf8) ?? ""
    }
}
