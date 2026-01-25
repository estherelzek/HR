//
//  Untitled.swift
//  HR
//
//  Created by Esther Elzek on 20/01/2026.
//

import Foundation

final class LunchSuppliersViewModel {

    func fetchLunchSuppliers(
        token: String,
        locationId: Int? = nil,
        completion: @escaping (Result<[LunchSupplier], APIError>) -> Void
    ) {
        let endpoint = API.lunchSuppliers(token: token, locationId: locationId)

        NetworkManager.shared.requestDecodable(
            endpoint,
            as: LunchSuppliersResponse.self
        ) { result in
            switch result {
            case .success(let response):
                guard response.success else {
                    completion(.failure(response.self  as! APIError))
                    return
                }
                completion(.success(response.suppliers))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
