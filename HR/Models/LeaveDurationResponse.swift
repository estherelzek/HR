//
//  LeaveDurationResponse.swift
//  HR
//
//  Created by Esther Elzek on 28/08/2025.
//

import Foundation

struct LeaveDurationResponse: Decodable {
    let jsonrpc: String?
    let id: String?
    let result: LeaveDurationResult?
}

struct LeaveDurationResult: Decodable {
    let success: Bool?
    let data: LeaveDurationData?
}

struct LeaveDurationData: Decodable {
    let leaveTypeUnit: String?
    let requestDateFrom: String?
    let requestDateTo: String?
    let dateFrom: String?
    let dateTo: String?

    let checkCasualLeave: Bool?
    let casualDaysCount: Double?
    let remainingCasualDays: Double?
    let casualLeaveWarning: Bool?

    let days: Double?
    let hours: Double?

    enum CodingKeys: String, CodingKey {
        case leaveTypeUnit = "leave_type_unit"
        case requestDateFrom = "request_date_from"
        case requestDateTo = "request_date_to"
        case dateFrom = "date_from"
        case dateTo = "date_to"

        case checkCasualLeave = "check_casual_leave"
        case casualDaysCount = "casual_days_count"
        case remainingCasualDays = "remaining_casual_days"
        case casualLeaveWarning = "casual_leave_warning"

        case days
        case hours
    }
}
