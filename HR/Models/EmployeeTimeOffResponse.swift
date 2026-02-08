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
    
    enum CodingKeys: String, CodingKey {
        case status
        case records
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        status = try container.decodeIfPresent(String.self, forKey: .status) ?? ""
        records = try container.decodeIfPresent(EmployeeTimeOffRecords.self, forKey: .records) ?? EmployeeTimeOffRecords()
    }
}

// MARK: - Records
struct EmployeeTimeOffRecords: Codable {
    let dailyRecords: [DailyRecord]
    let hourlyRecords: [HourlyRecord]

    enum CodingKeys: String, CodingKey {
        case dailyRecords = "daily_records"
        case hourlyRecords = "hourly_records"
    }
    
    init(
        dailyRecords: [DailyRecord] = [],
        hourlyRecords: [HourlyRecord] = []
    ) {
        self.dailyRecords = dailyRecords
        self.hourlyRecords = hourlyRecords
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        dailyRecords = try container.decodeIfPresent([DailyRecord].self, forKey: .dailyRecords) ?? []
        hourlyRecords = try container.decodeIfPresent([HourlyRecord].self, forKey: .hourlyRecords) ?? []
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
    var color: String?

    enum CodingKeys: String, CodingKey {
        case leaveID = "leave_id"
        case leaveType = "leave_type"
        case startDate = "start_date"
        case endDate = "end_date"
        case state
        case durationDays = "duration_days"
        case color
    }
}

// MARK: - Hourly Record
struct HourlyRecord: Codable {
    let leaveID: Int
    let leaveType: String
    let state: String
    let leaveDay: String
    let requestHourFrom: String?   // make optional
    let requestHourTo: String?     // make optional
    let durationHours: Double
    var color: String?
    
    enum CodingKeys: String, CodingKey {
        case leaveID = "leave_id"
        case leaveType = "leave_type"
        case state
        case leaveDay = "leave_day"
        case requestHourFrom = "request_hour_from"
        case requestHourTo = "request_hour_to"
        case durationHours = "duration_hours"
        case color = "color"
    }
}

