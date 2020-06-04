import Foundation

extension String {
    
    func parseJson() -> [String: Any]? {
        guard let data = self.data(using: String.Encoding.utf8) else {
            return nil
        }
                
        let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        return json
    }
}
