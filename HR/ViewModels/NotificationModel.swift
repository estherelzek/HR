//
//  File.swift
//  HR
//
//  Created by Esther Elzek on 30/11/2025.
//

import Foundation

struct NotificationModel: Identifiable, Codable {
    let id: String
    let title: String
    let message: String
    let date: Date
}

class NotificationStore {
    static let shared = NotificationStore()

    private let key = "saved_notifications"

    func save(_ notification: NotificationModel) {
        var all = load()
        all.append(notification)

        let data = try? JSONEncoder().encode(all)
        UserDefaults.standard.set(data, forKey: key)
    }

    func load() -> [NotificationModel] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        let items = try? JSONDecoder().decode([NotificationModel].self, from: data)
        return items ?? []
    }
}
