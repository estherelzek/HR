//
//  Order.swift
//  HR
//
//  Created by Esther Elzek on 11/02/2026.
//


import Foundation

struct Order: Codable {
    var productId: Int
    var name: String
    var quantity: Int
    var price: Double
    // Track if submitted / edited
        var isSubmitted: Bool = false
        var isEdited: Bool = false
}

struct HistoryOrder: Codable {
    let id: UUID
    let items: [Order]
    let total: Double
    let date: Date
    
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()

    var dateString: String {
        return Self.formatter.string(from: date)
    }
}

struct HistorySection {
    let date: String
    let orders: [HistoryOrder]
}
