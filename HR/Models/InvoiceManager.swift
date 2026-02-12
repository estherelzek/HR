//
//  InvoiceManager.swift
//  HR
//
//  Created by Esther Elzek on 11/02/2026.
//

// InvoiceManager.swift

import Foundation

class InvoiceManager {

    static let shared = InvoiceManager()   // 🔥 singleton

    private init() {}

    var orders: [Order] = []

    // Add new product to invoice
    func addProduct(_ product: LunchProduct, quantity: Int) {

        let price = Double(product.price) ?? 0.0

        // If already exists → increase quantity
        if let index = orders.firstIndex(where: { $0.name == product.name }) {
            orders[index].quantity += quantity
        } else {
            let newOrder = Order(
                id: UUID(),
                quantity: quantity,
                name: product.name,
                price: price
            )
            orders.append(newOrder)
        }
    }

    func increaseQuantity(at index: Int) {
        orders[index].quantity += 1
    }

    func decreaseQuantity(at index: Int) {
        guard index < orders.count else { return }

        orders[index].quantity -= 1

        if orders[index].quantity <= 0 {
            orders.remove(at: index)
        }
    }

    func removeItem(at index: Int) {
        guard index < orders.count else { return }
        orders.remove(at: index)
    }

    func totalPrice() -> Double {
        return orders.reduce(0) {
            $0 + (Double($1.quantity) * $1.price)
        }
    }

    func clearInvoice() {
        orders.removeAll()
    }
}
