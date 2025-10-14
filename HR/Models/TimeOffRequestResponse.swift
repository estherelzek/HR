//
//  TimeOffRequestResponse.swift
//  HR
//
//  Created by Esther Elzek on 31/08/2025.
//

import Foundation

struct TimeOffRequestResponse: Decodable {
    let jsonrpc: String?
    let id: String?
    let result: TimeOffRequestResult?
}

struct TimeOffRequestResult: Decodable {
    let status: String?          // "success" or "failed"
    let leaveId: Int?
    let message: String?
    let leaveType: String?
    let duration: Duration?
    let allocation: Allocation?

    enum CodingKeys: String, CodingKey {
        case status
        case leaveId = "leave_id"
        case message
        case leaveType = "leave_type"
        case duration
        case allocation
    }
}

struct Duration: Decodable {
    let value: Double?
    let unit: String?
}

struct Allocation: Decodable {
    let allocated: Double?
    let used: Double?
    let remaining: Double?
    let unit: String?
}
