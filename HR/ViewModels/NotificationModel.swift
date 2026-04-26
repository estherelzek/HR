//
//  File.swift
//  HR
//
//  Created by Esther Elzek on 30/11/2025.
//

import Foundation
import UIKit

struct NotificationModel: Identifiable, Codable {
    let id: String
    let title: String
    let message: String
    let date: Date
}

class NotificationStore {
    static let shared = NotificationStore()

    private let key = "saved_notifications"
    private let lastSeenCountKey = "last_seen_notification_count"

    func save(_ notification: NotificationModel) {
        var all = load()
        all.append(notification)

        let data = try? JSONEncoder().encode(all)
        UserDefaults.standard.set(data, forKey: key)
        updateBadgeCount()
    }

    func load() -> [NotificationModel] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        let items = try? JSONDecoder().decode([NotificationModel].self, from: data)
        return items ?? []
    }

    func count() -> Int {
        return load().count
    }

    func unreadCount() -> Int {
        let total = count()
        let lastSeen = UserDefaults.standard.integer(forKey: lastSeenCountKey)
        return max(total - lastSeen, 0)
    }

    func updateBadgeCount() {
        let badge = unreadCount()
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = badge
        }
    }

    func clearBadge() {
        UserDefaults.standard.set(count(), forKey: lastSeenCountKey)
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
}
