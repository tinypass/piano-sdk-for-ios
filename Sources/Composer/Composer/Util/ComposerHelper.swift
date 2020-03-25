import Foundation
import UIKit

internal class ComposerHelper {
    
    internal static func generateUserAgent() -> String {
        return "Piano composer SDK (iOS \(ProcessInfo.processInfo.operatingSystemVersionString) like Mac OS X; \(UIDevice.current.model))"
    }
    
    internal static func generatePageViewId() -> String {
        var pageViewIdParts: Array<String> = Array()
        let randomString16 = generateRandomString(length: 16)
        let randomString32 = generateRandomString(length: 32)
        let componetSet = Set<Calendar.Component>([.year, .month, .day, .hour, .minute, .second, .nanosecond])
        let now = Date()
        let components = Calendar.current.dateComponents(componetSet, from: now)
        
        pageViewIdParts.append(String(format: "%04d", components.year!))
        pageViewIdParts.append(String(format: "%02d", components.month!))
        pageViewIdParts.append(String(format: "%02d", components.day!))
        pageViewIdParts.append(String(format: "%02d", components.hour!))
        pageViewIdParts.append(String(format: "%02d", components.minute!))
        pageViewIdParts.append(String(format: "%02d", components.second!))
        pageViewIdParts.append(String(format: "%03d", components.nanosecond! / 1000000))
        pageViewIdParts.append(randomString16)
        pageViewIdParts.append(randomString32)
        return pageViewIdParts.joined(separator: "-")
    }
    
    internal static func generateVisitId() -> String {
        return "v-" + generatePageViewId();
    }
    
    internal static func generateRandomString(length: Int) -> String {
        let possibleSymbols = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        let possibleSymbolsCount = UInt32(possibleSymbols.count)
        var text: String = ""
        var rndIndex: Int
        
        for _ in 0..<length {
            rndIndex =  Int(arc4random_uniform(possibleSymbolsCount))
            text.append(possibleSymbols[possibleSymbols.index(possibleSymbols.startIndex, offsetBy: rndIndex)])
        }
        
        return text
    }
    
    // time zone offset in minutes
    internal static func getTimeZoneOffset() -> Int {
        return TimeZone.current.secondsFromGMT() / 60
    }
    
    internal static func getSdkVersion() -> String {
        if let version = Bundle(for: PianoComposer.self).infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }

        return "n/a";
    }
}
