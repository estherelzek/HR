//
//  PendingCheckAction.swift
//  HR
//
//  Created by Esther Elzek on 01/10/2025.
//

import Foundation

struct PendingAttendanceAction: Codable, Equatable {
    let action: String
    let workedHours: Double?
    let timestamp: Date
}

final class OfflineStorage {
    static let shared = OfflineStorage()
    private let key = "PendingAttendanceActions"

    private init() {}

    func save(action: PendingAttendanceAction) {
        var current = fetch()
        current.append(action)
        persist(current)
    }

    func fetch() -> [PendingAttendanceAction] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let actions = try? JSONDecoder().decode([PendingAttendanceAction].self, from: data) else {
            return []
        }
        return actions
    }

    func remove(actions: [PendingAttendanceAction]) {
        var current = fetch()
        current.removeAll { actions.contains($0) }
        persist(current)
    }

    private func persist(_ actions: [PendingAttendanceAction]) {
        if let data = try? JSONEncoder().encode(actions) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

