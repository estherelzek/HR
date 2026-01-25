//
//  LunchProductsViewModel.swift
//  HR
//
//  Created by Esther Elzek on 21/01/2026.
//

import Foundation


final class LunchProductsViewModel {

    func fetchProducts(
        token: String,
        categoryId: Int? = nil,
        locationId: Int? = nil,
        supplierId: Int? = nil,
        search: String? = nil,
        completion: @escaping (Result<[LunchProduct], Error>) -> Void
    ) {
        let endpoint = API.lunchProducts(
            token: token,
            locationId: locationId,
            categoryId: categoryId,
            supplierId: supplierId,
            search: search
        )

        NetworkManager.shared.requestDecodable(
            endpoint,
            as: LunchProductsResult.self
        ) { result in
            switch result {
            case .success(let response):
                completion(.success(response.products))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
