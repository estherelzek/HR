//
//  OrderHistoryManager.swift
//  HR
//
//  Created by Esther Elzek on 26/02/2026.
//

import Foundation


class HistoryManager {

    static let shared = HistoryManager()
    private init() { load() }

    private let key = "saved_history_orders"

    private(set) var orders: [HistoryOrder] = []

    func addOrder(_ items: [Order], total: Double) {
        let newOrder = HistoryOrder(
            id: UUID(),
            items: items,
            total: total,
            date: Date()
        )
        
        orders.append(newOrder)
        save()
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(orders)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Failed to save history:", error)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        do {
            orders = try JSONDecoder().decode([HistoryOrder].self, from: data)
        } catch {
            print("Failed to load history:", error)
        }
    }
}
