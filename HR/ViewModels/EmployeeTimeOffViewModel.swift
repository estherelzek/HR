//
//  EmployeeTimeOffViewModel.swift
//  HR
//
//  Created by Esther Elzek on 08/09/2025.
//

import Foundation

import Foundation

final class EmployeeTimeOffViewModel {

    func fetchEmployeeTimeOffs(
        token: String,
        completion: @escaping (Result<EmployeeTimeOffResult, APIError>) -> Void
    ) {
        let endpoint = API.getEmployeeTimeOffs(token: token, action: "time_off_status")
        
        NetworkManager.shared.requestDecodable(endpoint, as: EmployeeTimeOffResponse.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response.result))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
