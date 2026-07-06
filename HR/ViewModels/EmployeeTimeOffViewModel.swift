//
//  EmployeeTimeOffViewModel.swift
//  HR
//
//  Created by Esther Elzek on 08/09/2025.
//

import Foundation

final class EmployeeTimeOffViewModel {
    
    // MARK: - Completion-based method (legacy)
    func fetchEmployeeTimeOffs(
        token: String,
        completion: @escaping (Result<EmployeeTimeOffResult, APIError>) -> Void
    ) {
        let endpoint = API.getEmployeeTimeOffs(token: token, action: "time_off_status")
        
        NetworkManager.shared.requestDecodable(endpoint, as: EmployeeTimeOffResponse.self) { result in
            print("result Of time off : \(result)")
            switch result {
            case .success(let response):
                completion(.success(response.result))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Async/Await method (modern)
    
    /// Fetch employee time offs using async/await
    /// - Parameter token: Employee authentication token
    /// - Returns: EmployeeTimeOffResult
    /// - Throws: APIError if request fails
    func fetchEmployeeTimeOffs(token: String) async throws -> EmployeeTimeOffResult {
        let endpoint = API.getEmployeeTimeOffs(token: token, action: "time_off_status")
        
        // ✅ Await the network call
        let response = try await NetworkManager.shared.requestDecodable(endpoint, as: EmployeeTimeOffResponse.self)
        print("result Of time off : \(response)")
        
        return response.result
    }
}
