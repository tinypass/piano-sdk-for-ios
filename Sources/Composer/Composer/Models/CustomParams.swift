import Foundation

public class CustomParams: NSObject {
    
    private var content: Dictionary<String, Array<String>> = Dictionary<String, Array<String>>()
    
    private var user: Dictionary<String, Array<String>> = Dictionary<String, Array<String>>()
    
    private var request: Dictionary<String, Array<String>> = Dictionary<String, Array<String>>()
    
    public func content(key: String, value: String) -> CustomParams {
        put(dict: &content, key: key, value: value)
        return self;
    }
    
    public func user(key: String, value: String) -> CustomParams {
        put(dict: &user, key: key, value: value)
        return self;
    }
    
    public func request(key: String, value: String) -> CustomParams {
        put(dict: &request, key: key, value: value)
        return self;
    }
    
    private func put(dict: inout Dictionary<String, Array<String>>, key: String, value: String) {
        if dict[key] == nil {
            dict[key] = [String]()
        }
        
        dict[key]?.append(value)
    }
    
    public func toDictionary() -> [String: Any] {
        var dict = [String: Any]()
        dict["content"] = content
        dict["user"] = user
        dict["request"] = request
        return dict
    }
}
