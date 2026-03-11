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
    
    func scheduleCheckoutReminder(checkInTime: String, requiredHours: Double) {
        // Cancel any previous checkout reminder
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["checkout_reminder"])
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "UTC")
        
        guard let checkInDate = formatter.date(from: checkInTime) else {
            print("❌ Failed to parse checkInTime: \(checkInTime)")
            return
        }
        
        // Calculate when the employee should check out
        let checkoutTime = checkInDate.addingTimeInterval(requiredHours * 3600)
        
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
