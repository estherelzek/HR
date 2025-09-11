//
//  TimeOffRequestViewModel.swift
//  HR
//
//  Created by Esther Elzek on 31/08/2025.
//

import Foundation

class TimeOffRequestViewModel {
    
    func submitTimeOffRequest(
        token: String,
        leaveTypeId: Int,
        action: String,
        requestDateFrom: String,
        requestDateTo: String,
        requestDateFromPeriod: String,
        requestUnitHalf: Bool,
        hourFrom: String?,
        hourTo: String?,
        completion: @escaping (Result<TimeOffRequestResponse, APIError>) -> Void
    ) {
        let endpoint = API.submitTimeOffRequest(
            token: token,
            leaveTypeId: leaveTypeId,
            action: action,
            requestDateFrom: requestDateFrom,
            requestDateTo: requestDateTo,
            requestDateFromPeriod: requestDateFromPeriod,
            requestUnitHalf: requestUnitHalf,
            hourFrom: hourFrom,
            hourTo: hourTo
        )
        
        NetworkManager.shared.requestDecodable(endpoint, as: TimeOffRequestResponse.self, completion: completion)
    }
}
