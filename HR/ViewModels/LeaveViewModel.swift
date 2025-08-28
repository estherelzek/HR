//
//  LeaveViewModel.swift
//  HR
//
//  Created by Esther Elzek on 28/08/2025.
//

import Foundation

final class LeaveDurationViewModel {
    
    func fetchLeaveDuration(
        token: String,
        leaveTypeId: Int,
        requestDateFrom: String,
        requestDateTo: String,
        requestDateFromPeriod: String,
        requestUnitHalf: Bool,
        requestHourFrom: String? = nil,
        requestHourTo: String? = nil,
        requestUnitHours: Bool,
        completion: @escaping (Result<LeaveDurationData, APIError>) -> Void
    ) {
        let endpoint = API.leaveDuration(
            token: token,
            leaveTypeId: leaveTypeId,
            requestDateFrom: requestDateFrom,
            requestDateTo: requestDateTo,
            requestDateFromPeriod: requestDateFromPeriod,
            requestUnitHalf: requestUnitHalf,
            requestHourFrom: requestHourFrom,
            requestHourTo: requestHourTo,
            requestUnitHours: requestUnitHours
        )
        
        NetworkManager.shared.requestDecodable(endpoint, as: LeaveDurationResponse.self) { result in
            switch result {
            case .success(let response):
                if let data = response.result?.data {
                    completion(.success(data))
                } else {
                    completion(.failure(.noData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
