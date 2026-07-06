//
//  TimeOffViewModel.swift
//  HR
//
//  Created by Esther Elzek on 27/08/2025.
//

import Foundation

final class TimeOffViewModel {
    // MARK: - Completion-based methods (legacy)
    func fetchTimeOff(token: String, completion: @escaping (Result<TimeOffResponse, APIError>) -> Void) {
        let endpoint = API.requestTimeOff(token: token, action: "get_employee_leave_type")
        NetworkManager.shared.requestDecodable(endpoint, as: TimeOffResponse.self, completion: completion)
    }
    
    func fetchHolidays(token: String, completion: @escaping (Result<HolidayResult, APIError>) -> Void) {
        let endpoint = API.requestTimeOff(token: token, action: "weekend_request")
        NetworkManager.shared.requestDecodable(endpoint, as: HolidayResponse.self) { result in
            switch result {
            case .success(let response):
                if let result = response.result {
                    completion(.success(result))
                } else {
                    completion(.failure(.noData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Async/Await methods (modern)
    
    /// Fetch time off data using async/await
    /// - Parameter token: Employee authentication token
    /// - Returns: TimeOffResponse
    /// - Throws: APIError if request fails
    func fetchTimeOff(token: String) async throws -> TimeOffResponse {
        let endpoint = API.requestTimeOff(token: token, action: "get_employee_leave_type")
        // ✅ Simply await the network call - no completion handler needed!
        return try await NetworkManager.shared.requestDecodable(endpoint, as: TimeOffResponse.self)
    }
    
    /// Fetch holidays using async/await
    /// - Parameter token: Employee authentication token
    /// - Returns: HolidayResult
    /// - Throws: APIError if request fails or no data
    func fetchHolidays(token: String) async throws -> HolidayResult {
        let endpoint = API.requestTimeOff(token: token, action: "weekend_request")
        // ✅ Await the network call
        let response = try await NetworkManager.shared.requestDecodable(endpoint, as: HolidayResponse.self)
        
        // ✅ Handle optional result - throw error if missing
        guard let result = response.result else {
            throw APIError.noData
        }
        return result
    }
}
