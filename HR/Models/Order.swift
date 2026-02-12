//
//  Order.swift
//  HR
//
//  Created by Esther Elzek on 11/02/2026.
//


import Foundation

struct Order: Identifiable {
    let id: UUID
    var quantity: Int
    let name: String
    let price: Double
}
