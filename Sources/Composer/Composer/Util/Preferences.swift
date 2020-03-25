import Foundation

internal class Preferences {
    
    internal static func clearPreferences() {
        let userDefaults = UserDefaults.standard
        
        userDefaults.removeObject(forKey: CookieData.xbcKeyName)
        userDefaults.removeObject(forKey: CookieData.tbcKeyName)
        userDefaults.removeObject(forKey: CookieData.tacKeyName)
        
        userDefaults.removeObject(forKey: Visit.visitIdKeyName)
        userDefaults.removeObject(forKey: Visit.visitTimeKeyName)
        
        userDefaults.removeObject(forKey: VisitPreferences.appTimezoneOffsetKeyName)
        userDefaults.removeObject(forKey: VisitPreferences.visitTimeoutKeyName)
    }
    
    internal static func loadCookies() -> CookieData {
        let userDefaults = UserDefaults.standard
        let xbc = userDefaults.string(forKey: CookieData.xbcKeyName) ?? ""
        let tbc = userDefaults.string(forKey: CookieData.tbcKeyName) ?? ""
        let tac = userDefaults.string(forKey: CookieData.tacKeyName) ?? ""
        return CookieData(xbc: xbc, tbc: tbc, tac: tac)
    }
    
    internal static func saveCookies(data: CookieData) {
        let userDefaults = UserDefaults.standard
        userDefaults.setValuesForKeys(data.toDictionary())
    }
    
    internal static func loadVisit() -> Visit {
        let userDefaults = UserDefaults.standard
        let id = userDefaults.string(forKey: Visit.visitIdKeyName) ?? ""
        let time = userDefaults.double(forKey: Visit.visitTimeKeyName)
        return Visit(id: id, time: time)
    }
    
    internal static func saveVisit(visit: Visit) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(visit.id, forKey: Visit.visitIdKeyName)
        userDefaults.set(visit.time, forKey: Visit.visitTimeKeyName)
    }
    
    internal static func loadVisitPreferences() -> VisitPreferences {
        let userDefaults = UserDefaults.standard
        let appTimezoneOffset = userDefaults.integer(forKey: VisitPreferences.appTimezoneOffsetKeyName)
        let visitTimeout = userDefaults.integer(forKey: VisitPreferences.visitTimeoutKeyName)
        return VisitPreferences(appTimezoneOffset: appTimezoneOffset, visitTimeout: visitTimeout)
    }
    
    internal static func saveVisitPreferences(visitPreferences: VisitPreferences) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(visitPreferences.appTimezoneOffset, forKey: VisitPreferences.appTimezoneOffsetKeyName)
        userDefaults.set(visitPreferences.visitTimeout, forKey: VisitPreferences.visitTimeoutKeyName)
    }
    
    // Preferences models
    internal class CookieData {
        
        internal static let xbcKeyName = "io.piano.composer.xbc"
        internal static let tbcKeyName = "io.piano.composer.tbc"
        internal static let tacKeyName = "io.piano.composer.tac"
        
        internal let xbc: String
        internal let tbc: String
        internal let tac: String
        
        internal init(xbc: String, tbc: String, tac: String) {
            self.xbc = xbc
            self.tbc = tbc
            self.tac = tac
        }
        
        internal func toDictionary() -> Dictionary<String, String> {
            var dict = Dictionary<String, String>()
            dict[CookieData.xbcKeyName] = xbc
            dict[CookieData.tbcKeyName] = tbc
            dict[CookieData.tacKeyName] = tac
            return dict
        }
    }
    
    internal class Visit {
        
        internal static let visitIdKeyName = "io.piano.composer.visit.id"
        internal static let visitTimeKeyName = "io.piano.composer.visit.time"
        
        internal var id: String
        internal var time: TimeInterval
        
        internal init(id: String, time: TimeInterval) {
            self.id = id
            self.time = time
        }
        
        internal func isEmpty() -> Bool {
            return id.isEmpty && time == 0
        }
        
        internal func isExpired(visitPreferences: VisitPreferences) -> Bool {
            let now = Date()            
            if self.time.toMillis() + Int64(visitPreferences.visitTimeout) < now.timeIntervalSince1970.toMillis() {
                return true
            }
            
            let componetSet = Set<Calendar.Component>([.timeZone, .year, .month, .day, .hour, .minute, .second, .nanosecond])
            var components = Calendar.current.dateComponents(componetSet, from: now)
            components.hour = 0
            components.minute = 0
            components.second = 0
            components.nanosecond = 0
            components.timeZone = TimeZone(secondsFromGMT: visitPreferences.appTimezoneOffset / 1000)
            let midnight = Calendar.current.date(from: components)?.toUnixTimestamp() ?? 0
            
            return self.time.toMillis() < midnight
        }
    }
    
    internal class VisitPreferences {
        
        internal static let appTimezoneOffsetKeyName = "io.piano.composer.appSettings.appTimezoneOffset"
        internal static let visitTimeoutKeyName = "io.piano.composer.appSettings.visitTimeout"
        
        internal var visitTimeout: Int
        internal var appTimezoneOffset: Int
        
        internal init(appTimezoneOffset:Int, visitTimeout: Int) {
            self.appTimezoneOffset = appTimezoneOffset
            self.visitTimeout = visitTimeout
        }        
    }
}
