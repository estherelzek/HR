//
//  EmployeeTimeOffResponse.swift
//  HR
//
//  Created by Esther Elzek on 08/09/2025.
//

import Foundation
// MARK: - Root Response
struct EmployeeTimeOffResponse: Codable {
    let jsonrpc: String
    let id: String?
    let result: EmployeeTimeOffResult
}

// MARK: - Result
struct EmployeeTimeOffResult: Codable {
    let status: String
    let records: EmployeeTimeOffRecords
}

// MARK: - Records
struct EmployeeTimeOffRecords: Codable {
    let dailyRecords: [DailyRecord]
    let hourlyRecords: [HourlyRecord]

    enum CodingKeys: String, CodingKey {
        case dailyRecords = "daily_records"
        case hourlyRecords = "hourly_records"
    }
}

// MARK: - Daily Record
struct DailyRecord: Codable {
    let leaveID: Int
    let leaveType: String
    let startDate: String
    let endDate: String
    let state: String
    let durationDays: Double

    enum CodingKeys: String, CodingKey {
        case leaveID = "leave_id"
        case leaveType = "leave_type"
        case startDate = "start_date"
        case endDate = "end_date"
        case state
        case durationDays = "duration_days"
    }
}

// MARK: - Hourly Record
struct HourlyRecord: Codable {
    let leaveID: Int
    let leaveType: String
    let startDate: String
    let endDate: String
    let state: String
    let durationHours: Double

    enum CodingKeys: String, CodingKey {
        case leaveID = "leave_id"
        case leaveType = "leave_type"
        case startDate = "start_date"
        case endDate = "end_date"
        case state
        case durationHours = "duration_hours"
    }
}
