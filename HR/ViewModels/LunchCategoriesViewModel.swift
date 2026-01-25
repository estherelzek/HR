//
//  LunchCategoriesViewModel.swift
//  HR
//
//  Created by Esther Elzek on 21/01/2026.
//

import Foundation
final class LunchCategoriesViewModel {

    func fetchCategories(
        token: String,
        completion: @escaping (Result<[LunchCategory], APIError>) -> Void
    ) {
        let endpoint = API.lunchCategories(token: token)

        NetworkManager.shared.requestDecodable(
            endpoint,
            as: LunchCategoriesResponse.self
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard response.success else {
                        completion(.failure(response.self  as! APIError))
                        return
                    }
                    completion(.success(response.categories))

                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}
