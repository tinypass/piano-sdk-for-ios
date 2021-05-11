import Foundation

public class OptionalBool: NSObject, Codable, ExpressibleByBooleanLiteral {
    public typealias BooleanLiteralType = Bool

    @objc public let value: Bool

    public required init(booleanLiteral value: Bool) {
        self.value = value
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(Bool.self)
    }

    @objc public static func from(_ from: ObjCBool) -> OptionalBool {
        OptionalBool(booleanLiteral: from.boolValue)
    }
}

public class OptionalInt: NSObject, Codable, ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int

    @objc public let value: Int

    public required init(integerLiteral value: Int) {
        self.value = value
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(Int.self)
    }

    @objc public static func from(_ from: Int) -> OptionalInt {
        OptionalInt(integerLiteral: from)
    }
}

public class OptionalDouble: NSObject, Codable, ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = Double

    @objc public let value: Double

    public required init(floatLiteral value: Double) {
        self.value = value
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(Double.self)
    }

    @objc public static func from(_ from: Double) -> OptionalDouble {
        OptionalDouble(floatLiteral: from)
    }
}

@objc
public enum JSONValueType: Int {
    case null, bool, int, double, string, array, object
}

public class JSONValue: NSObject, Codable {

    public let type: JSONValueType
    public let value: Any?

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let v = try? container.decode(Bool.self) {
            (type, value) = (.bool, v)
            return
        }

        if let v = try? container.decode(Int.self) {
            (type, value) = (.int, v)
            return
        }

        if let v = try? container.decode(Double.self) {
            (type, value) = (.double, v)
            return
        }

        if let v = try? container.decode(String.self) {
            (type, value) = (.string, v)
            return
        }

        if let v = try? container.decode([JSONValue].self) {
            (type, value) = (.array, v)
            return
        }

        if let v = try? container.decode([String: JSONValue].self) {
            (type, value) = (.object, v)
            return
        }

        (type, value) = (.null, nil)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch type {
        case .bool: try container.encode(value as! Bool)
        case .int: try container.encode(value as! Int)
        case .double: try container.encode(value as! Double)
        case .string: try container.encode(value as! String)
        case .array: try container.encode(value as! [JSONValue])
        case .object: try container.encode(value as! [String: JSONValue])
        default: try container.encodeNil()
        }
    }
}

public class PianoAPIError: LocalizedError {
    @objc public let message: String

    internal init(_ message: String) {
        self.message = message
    }

    public var errorDescription: String? {
        "PianoAPIError:\n\t\(message)"
    }
}

@objcMembers
public class PianoAPIEndpoint: NSObject {

    public static var production: PianoAPIEndpoint {
        PianoAPIEndpoint(url: "https://buy.piano.io")
    }

    public static var productionAustralia: PianoAPIEndpoint {
        PianoAPIEndpoint(url: "https://buy-au.piano.io")
    }

    public static var productionAsiaPacific: PianoAPIEndpoint {
        PianoAPIEndpoint(url: "https://buy-ap.piano.io")
    }

    public static var sandbox: PianoAPIEndpoint {
        PianoAPIEndpoint(url: "https://sandbox.piano.io")
    }

    public let url: String

    public init(url: String) {
        self.url = url
    }
}

public class PianoAPI: NSObject {

    internal enum HttpMethod: String {
        case post = "POST"
        case get = "GET"
        case options = "OPTIONS"

        internal static func from(_ method: String) -> HttpMethod {
            switch method.uppercased() {
            case "POST":
                return HttpMethod.post
            case "OPTIONS":
                return HttpMethod.options
            default:
                return HttpMethod.get
            }
        }
    }

    internal class Client {

        private static let exclude = ["code", "ts", "count", "limit", "offset", "total", "message", "validation_errors"]

        private let endpoint: PianoAPIEndpoint
        private let decoder = JSONDecoder()
        private let encoder = JSONEncoder()
        private let session: URLSession

        init(endpoint: PianoAPIEndpoint) {
            self.endpoint = endpoint

            decoder.dateDecodingStrategy = .secondsSince1970
            session = URLSession(configuration: URLSessionConfiguration.default)
        }

        private func request(path: String, method: HttpMethod, params: [String: String]? = nil, completion: @escaping (Data?, Error?) -> Void) {
            let urlStr = "\(endpoint.url)\(path)"
            guard var urlBuilder = URLComponents(string: urlStr) else {
                completion(nil, PianoAPIError("Failed parse url \(urlStr)"))
                return
            }

            if (method == .get || method == .options) && params != nil {
                urlBuilder.queryItems = params!.map { key, value in URLQueryItem(name: key, value: value)  }
            }

            guard let url = urlBuilder.url else {
                completion(nil, PianoAPIError("Failed make url \(urlBuilder.string ?? "")"))
                return
            }

            var req = URLRequest(url: url)

            if method == .post && params != nil {
                var data = [String]()
                for(key, value) in params! {
                    data.append(key + "=\(value)")
                }
                req.httpBody = data.joined(separator: "&").data(using: .utf8)
            }

            req.httpMethod = method.rawValue

            session.dataTask(with: req) { (data, response, error) in
                if let e = error {
                    completion(nil, e)
                    return
                }

                guard let r = response as? HTTPURLResponse else {
                    completion(nil, PianoAPIError("Failed parse response"))
                    return
                }

                if r.statusCode != 200 {
                    completion(nil, PianoAPIError("Invalid response status \(r.statusCode)"))
                    return
                }

                guard let d = data else {
                    completion(nil, PianoAPIError("Failed parse response data"))
                    return
                }

                completion(d, nil)
            }.resume()
        }

        func request(path: String, method: HttpMethod, params: [String: String]? = nil, completion: @escaping (Error?) -> Void) {
            request(path: path, method: method, params: params) { [self] (data, error) in
                if let e = error {
                    completion(e)
                    return
                }

                do {
                    _ = try parseAndCheck(data!)
                    completion(nil)
                } catch {
                    completion(error)
                }
            }
        }

        func request<T : Codable>(path: String, method: HttpMethod, params: [String: String]? = nil, completion: @escaping (T?, Error?) -> Void) {
            request(path: path, method: method, params: params) { [self] (data, error) in
                if let e = error {
                    completion(nil, e)
                    return
                }

                do {
                    if T.self is JSONValue.Type {
                        completion(try decoder.decode(T.self, from: data!), nil)
                    } else {
                        completion(try decoder.decode(T.self, from: try getData(parseAndCheck(data!))), nil)
                    }
                } catch {
                    completion(nil, error)
                }
            }
        }

        func request<T : Codable>(path: String, method: HttpMethod, params: [String: String]? = nil, defaultValue: T, completion: @escaping (T, Error?) -> Void) {
            request(path: path, method: method, params: params) { [self] (data, error) in
                if let e = error {
                    completion(defaultValue, e)
                    return
                }

                do {
                    if T.self is JSONValue.Type {
                        completion(try decoder.decode(T.self, from: data!), nil)
                    } else {
                        completion(try decoder.decode(T.self, from: try getData(parseAndCheck(data!))), nil)
                    }
                } catch {
                    completion(defaultValue, error)
                }
            }
        }

        func parseAndCheck(_ data: Data) throws -> [String:JSONValue] {
            let result = try decoder.decode([String:JSONValue].self, from: data)
            guard let code = (result["code"]?.value as? Int) else {
                throw PianoAPIError("Result code undefined")
            }
            if code != 0 {
               throw getError(code: code, result: result)
            }
            return result
        }

        func getData(_ result: [String:JSONValue]) throws -> Data {
            let keys = result.keys.filter { s in !PianoAPI.Client.exclude.contains(s) }
            if keys.count != 1 {
                throw PianoAPIError("Failed parse result data")
            }
            return try encoder.encode(result[keys[0]])
        }

        private func getError(code: Int, result: [String:JSONValue]) -> PianoAPIError {
            var message: String
            if let ve = result["validation_errors"]?.value as? [String:JSONValue], let m = ve["message"]?.value as? String {
                message = m
            } else if let m = result["message"]?.value as? String {
                message = m
            } else {
                message = "Invalid code"
            }

            return PianoAPIError("Code: \(code), Message: \(message)")
        }
    }

    internal var client: Client?

    @objc public static let shared = PianoAPI()

    private override init() {}

    @objc public func initialize(endpoint: PianoAPIEndpoint) {
        client = Client(endpoint: endpoint)
    }

    @objc public private(set) lazy var access = AccessAPI()
    @objc public private(set) lazy var accessToken = AccessTokenAPI()
    @objc public private(set) lazy var amp = AmpAPI()
    @objc public private(set) lazy var anonAssets = AnonAssetsAPI()
    @objc public private(set) lazy var anonError = AnonErrorAPI()
    @objc public private(set) lazy var anonMobileSdkIdDeployment = AnonMobileSdkIdDeploymentAPI()
    @objc public private(set) lazy var anonUser = AnonUserAPI()
    @objc public private(set) lazy var conversion = ConversionAPI()
    @objc public private(set) lazy var conversionExternal = ConversionExternalAPI()
    @objc public private(set) lazy var conversionRegistration = ConversionRegistrationAPI()
    @objc public private(set) lazy var emailConfirmation = EmailConfirmationAPI()
    @objc public private(set) lazy var oauth = OauthAPI()
    @objc public private(set) lazy var subscription = SubscriptionAPI()
    @objc public private(set) lazy var swgSync = SwgSyncAPI()
}
