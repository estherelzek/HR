//
//  TimeOffViewModel.swift
//  HR
//
//  Created by Esther Elzek on 27/08/2025.
//

import Foundation

final class TimeOffViewModel {
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
}
