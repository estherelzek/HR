//
//  InvoiceManager.swift
//  HR
//
//  Created by Esther Elzek on 11/02/2026.
//

// InvoiceManager.swift

import Foundation

class InvoiceManager {

    static let shared = InvoiceManager()
    private init() { loadOrders() }

    private let ordersKey = "savedOrders"

    var orders: [Order] = []
    var isSubmitted: Bool = false
    var isEdited: Bool = false

    // MARK: - Add / modify
    func addProduct(_ product: LunchProduct, quantity: Int) {
        if let index = orders.firstIndex(where: { $0.productId == product.id }) {
            orders[index].quantity += quantity
            markEdited()
        } else {
            let order = Order(
                productId: product.id,
                name: product.name,
                quantity: quantity,
                price: Double(product.price) ?? 0
            )
            orders.append(order)
            markEdited()
        }
        saveOrders()
    }

    func increaseQuantity(at index: Int) {
        orders[index].quantity += 1
        markEdited()
        saveOrders()
    }

    func decreaseQuantity(at index: Int) {
        guard index < orders.count else { return }

        orders[index].quantity -= 1
        markEdited()

        if orders[index].quantity <= 0 {
            orders.remove(at: index)
        }
        saveOrders()
    }

    func removeItem(at index: Int) {
        guard index < orders.count else { return }
        orders.remove(at: index)
        markEdited()
        saveOrders()
    }

    func totalPrice() -> Double {
        return orders.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }

    func clearInvoice() {
        orders.removeAll()
        isSubmitted = false
        isEdited = false
        saveOrders()
    }

    // MARK: - State helpers
    func markSubmitted() {
        isSubmitted = true
        isEdited = false
        orders = orders.map { order in
            var o = order
            o.isSubmitted = true
            o.isEdited = false
            return o
        }
        saveOrders()
    }

    func markEdited() {
        guard isSubmitted else { return } // only track edits after submission
        isEdited = true
        orders = orders.map { order in
            var o = order
            o.isEdited = true
            return o
        }
        saveOrders()
    }

    // MARK: - Persistence
    private func saveOrders() {
        do {
            let data = try JSONEncoder().encode(orders)
            UserDefaults.standard.set(data, forKey: ordersKey)
            UserDefaults.standard.set(isSubmitted, forKey: "\(ordersKey)_submitted")
            UserDefaults.standard.set(isEdited, forKey: "\(ordersKey)_edited")
        } catch {
            print("Failed to save orders:", error)
        }
    }

    private func loadOrders() {
        guard let data = UserDefaults.standard.data(forKey: ordersKey) else { return }
        do {
            orders = try JSONDecoder().decode([Order].self, from: data)
            isSubmitted = UserDefaults.standard.bool(forKey: "\(ordersKey)_submitted")
            isEdited = UserDefaults.standard.bool(forKey: "\(ordersKey)_edited")
        } catch {
            print("Failed to load orders:", error)
        }
    }
    
   
    func loadOrder(_ historyOrder: HistoryOrder) {
        orders = historyOrder.items
        isSubmitted = false
        isEdited = false
        
        saveOrders()
        NotificationCenter.default.post(name: .invoiceUpdated, object: nil)
    }
}
