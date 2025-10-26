//
//  ClockChangeDetector.swift
//  HR
//
//  Created by Esther Elzek on 16/10/2025.
//


import Foundation
import UIKit

final class ClockChangeDetector: NSObject {
    static let shared = ClockChangeDetector()
    private(set) var clockChanged = false

    private let baselineKey = "clockBaselineTime"
    private let diffKey = "clockDifferenceMinutes"

    private override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(systemClockDidChange),
            name: NSNotification.Name.NSSystemClockDidChange,
            object: nil
        )
        print("🕒 ClockChangeDetector initialized — observing clock changes.")
        
    }

//    /// Called when a valid server time is received (used to reset baseline)
//    func updateBaseline(serverTimeUTC: String) {
//        guard let serverDate = Self.parseServerDate(serverTimeUTC) else { return }
//        let defaults = UserDefaults.standard
//
//        // Save the baseline
//        defaults.set(serverDate.timeIntervalSince1970, forKey: baselineKey)
//
//        // 🕒 Also save initial "afterKey" snapshot for comparison
//        defaults.set(serverDate.timeIntervalSince1970, forKey: "lastClockAfterChangeKey")
//
//        defaults.synchronize()
//        clockChanged = false
//        print("🕒 ✅ Baseline + afterKey initialized from server: \(serverTimeUTC)")
//    }

//    func initializeBaselineIfNeeded(token: String, getServerTime: @escaping (String, @escaping (Result<ServerTimeResponse, Error>) -> Void) -> Void) {
//        let defaults = UserDefaults.standard
//        getServerTime(token) { result in
//            switch result {
//            case .success(let serverResponse):
//                guard let serverTime = serverResponse.result?.serverTime else {
//                    print("⚠️ Could not retrieve server time for baseline initialization.")
//                    return
//                }
//                self.updateBaseline(serverTimeUTC: serverTime)
//
//            case .failure(let error):
//                print("⚠️ Failed to fetch server time for baseline: \(error.localizedDescription)")
//            }
//        }
//    }

    @objc private func systemClockDidChange() {
        print("🕒⚠️ System clock change detected → user modified device time manually.")
        clockChanged = true

//        let currentDate = Date()
//        let defaults = UserDefaults.standard
//
//        let beforeKey = "lastClockBeforeChangeKey"
//        let afterKey = "lastClockAfterChangeKey"
//
//        // Fetch the last known time before change
//        let previousClock = defaults.value(forKey: afterKey) as? TimeInterval
//
//        if let lastAfterTimestamp = previousClock {
//            let lastAfterDate = Date(timeIntervalSince1970: lastAfterTimestamp)
//            let differenceMinutes = Int((currentDate.timeIntervalSince(lastAfterDate)) / 60.0)
//
//            print("🕒 Previous clock: \(lastAfterDate)")
//            print("🕒 New clock: \(currentDate)")
//            print("🕒 Difference detected: \(differenceMinutes) minutes")
//
//            // Save both states
//            defaults.set(lastAfterTimestamp, forKey: beforeKey)
//            defaults.set(currentDate.timeIntervalSince1970, forKey: afterKey)
//            defaults.set(differenceMinutes, forKey: "clockDiffMinutes")
//        } else {
//            // First time setup — initialize both
//            defaults.set(currentDate.timeIntervalSince1970, forKey: beforeKey)
//            defaults.set(currentDate.timeIntervalSince1970, forKey: afterKey)
//            print("🕒 First baseline initialized at \(currentDate)")
//        }
        UserDefaults.standard.set("-1000",forKey: "clockDiffMinutes")

    }

    /// Optional reset (e.g., after going online)
    func resetFlag() {
        clockChanged = false
        print("🕒🔄 ClockChangeDetector flag reset.")
    }

    /// Retrieve saved difference (in minutes)
    func getClockDifference() -> Int {
        return UserDefaults.standard.integer(forKey: diffKey)
    }

//    private static func parseServerDate(_ utcString: String) -> Date? {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        formatter.timeZone = TimeZone(abbreviation: "UTC")
//        return formatter.date(from: utcString)
//    }
//
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//    /// Compare current clock with baseline to detect manual time changes
//    func verifyClockDifference(thresholdMinutes: Int = 2) {
//        let defaults = UserDefaults.standard
//        guard let baselineTimestamp = defaults.value(forKey: baselineKey) as? TimeInterval else {
//            print("🕒 No baseline found for comparison.")
//            return
//        }
//
//        let baselineDate = Date(timeIntervalSince1970: baselineTimestamp)
//        let currentDate = Date()
//
//        let differenceMinutes = abs(Int((currentDate.timeIntervalSince(baselineDate)) / 60.0))
//        print("🕒 Baseline: \(baselineDate)")
//        print("🕒 Current: \(currentDate)")
//        print("🕒 Difference since baseline: \(differenceMinutes) minutes")
//
//        defaults.set(differenceMinutes, forKey: "clockDiffMinutes")
//
//        if differenceMinutes > thresholdMinutes {
//            print("⚠️ Significant clock difference detected (\(differenceMinutes) min) — possible manual change!")
//            clockChanged = true
//        }
//    }

}
