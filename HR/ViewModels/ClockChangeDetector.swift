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

    /// Called when a valid server time is received (used to reset baseline)
    func updateBaseline(serverTimeUTC: String) {
        clockChanged = false
        print("🕒 ✅ Baseline updated from server: \(serverTimeUTC)")
    }

    /// Triggered automatically when system time changes
    @objc private func systemClockDidChange() {
        print("🕒⚠️ System clock change detected → user modified device time manually.")
        clockChanged = true
    }

    /// Optional reset (e.g., after going online)
    func resetFlag() {
        clockChanged = false
        print("🕒🔄 ClockChangeDetector flag reset.")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//import Foundation
//
//struct TimeSyncManager {
//    static let shared = TimeSyncManager()
//
//    private let serverTimeKey = "LastServerTime"
//    private let deviceTimeKey = "LastDeviceTime"
//
//    /// Save both the last known server and device timestamps
//    func saveSync(serverDate: Date) {
//        let deviceDate = Date()
//        UserDefaults.standard.set(serverDate.timeIntervalSince1970, forKey: serverTimeKey)
//        UserDefaults.standard.set(deviceDate.timeIntervalSince1970, forKey: deviceTimeKey)
//        print("🕒 [TimeSyncManager] Saved → server: \(serverDate) | device: \(deviceDate)")
//    }
//
//    /// Check if stored
//    func hasSyncedBefore() -> Bool {
//        return UserDefaults.standard.value(forKey: serverTimeKey) != nil &&
//               UserDefaults.standard.value(forKey: deviceTimeKey) != nil
//    }
//
//    /// Compare accuracy of current clock vs last sync
//    func isClockTampered() -> Bool {
//        guard
//            let lastServerTimestamp = UserDefaults.standard.value(forKey: serverTimeKey) as? TimeInterval,
//            let lastDeviceTimestamp = UserDefaults.standard.value(forKey: deviceTimeKey) as? TimeInterval
//        else {
//            print("⚠️ No stored sync info — assuming first launch.")
//            return false
//        }
//
//        // Elapsed time since last sync (based on device)
//        let deviceElapsed = Date().timeIntervalSince(Date(timeIntervalSince1970: lastDeviceTimestamp))
//        let expectedServerTime = Date(timeIntervalSince1970: lastServerTimestamp + deviceElapsed)
//        let deviation = abs(expectedServerTime.timeIntervalSinceNow)
//
//        print("""
//        📊 [Time Accuracy Check]
//        ├─ Last Server: \(Date(timeIntervalSince1970: lastServerTimestamp))
//        ├─ Last Device: \(Date(timeIntervalSince1970: lastDeviceTimestamp))
//        ├─ Expected Server Now: \(expectedServerTime)
//        ├─ Device Now: \(Date())
//        └─ Deviation: \(deviation) seconds
//        """)
//
//        return deviation > 120 // >2 min = likely manual change
//    }
//}
