//
//  NotificationManager.swift
//  HR
//
//  Created by Esther Elzek on 03/03/2026.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    // Set to a value like 2 for testing reminder delivery in minutes.
    // Keep nil in normal app behavior to use backend scheduled hours.
    private let checkoutReminderTestMinutes: Double? = nil
    
    func scheduleCheckoutReminder(checkInTime: String, requiredHours: Double) {
        // Cancel any previous checkout reminder
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["checkout_reminder"])

        // Try parsing server time as UTC first, then fall back to local time.
        let utcFormatter = DateFormatter()
        utcFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        utcFormatter.timeZone = TimeZone(identifier: "UTC")

        let localFormatter = DateFormatter()
        localFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        localFormatter.timeZone = .current

        let parsedCheckInDate = utcFormatter.date(from: checkInTime) ?? localFormatter.date(from: checkInTime)

        let baseDate: Date
        if let parsedCheckInDate {
            baseDate = parsedCheckInDate
            print("🕒 Parsed check-in time successfully: \(parsedCheckInDate)")
        } else {
            print("❌ Failed to parse checkInTime: \(checkInTime). Falling back to current time for scheduling.")
            baseDate = Date()
        }
        
        // Calculate when the employee should check out
        let interval: TimeInterval
        if let testMinutes = checkoutReminderTestMinutes {
            interval = testMinutes * 60
            print("🧪 Using test checkout reminder override: \(testMinutes) minute(s)")
        } else {
            interval = requiredHours * 3600
        }

        var checkoutTime = baseDate.addingTimeInterval(interval)

        // In test mode, if backend time is behind device time, schedule from now instead.
        if let testMinutes = checkoutReminderTestMinutes, checkoutTime <= Date() {
            checkoutTime = Date().addingTimeInterval(testMinutes * 60)
            print("🧪 Adjusted test reminder to current time + \(testMinutes) minute(s): \(checkoutTime)")
        }
        
        // Make sure it's in the future
        guard checkoutTime > Date() else {
            print("⚠️ Checkout time is already in the past, skipping notification")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("checkout_reminder_title", comment: "Time to Check Out")
        content.body = NSLocalizedString("checkout_reminder_body", comment: "You've completed your working hours. Don't forget to check out!")
        content.sound = .default
        content.badge = 1
        
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: checkoutTime
        )
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "checkout_reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule checkout notification: \(error)")
            } else {
                print("✅ Checkout reminder scheduled for: \(checkoutTime)")
            }
        }
    }
    
    func cancelCheckoutReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["checkout_reminder"])
        print("🗑️ Checkout reminder cancelled")
    }
}
