//
//  LunchOrdersViewModel.swift
//  HR
//
//  Created by Esther Elzek on 24/02/2026.
//

import Foundation
final class LunchOrdersViewModel {

    func submitOrder(
        token: String,
        orders: [Order],
        completion: @escaping (Result<LunchOrderResponse, APIError>) -> Void
    ) {

        let apiOrders: [[String: Any]] = orders
            .filter { $0.quantity > 0 }
            .map {
                [
                    "product_id": $0.productId,
                    "quantity": $0.quantity,
                    "total_price": Double($0.quantity) * $0.price
                ]
            }

        let endpoint = API.lunchOrders(token: token, orders: apiOrders)

        NetworkManager.shared.requestDecodable(
            endpoint,
            as: LunchOrderResponse.self
        ) { result in

            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
