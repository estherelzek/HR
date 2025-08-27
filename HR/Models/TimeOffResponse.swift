//
//  TimeOffResponse.swift
//  HR
//
//  Created by Esther Elzek on 27/08/2025.
//

import Foundation

struct TimeOffResponse: Decodable {
    let result: TimeOffResult?
}

struct TimeOffResult: Decodable {
    let status: String
    let leaveTypes: [LeaveType]

    enum CodingKeys: String, CodingKey {
        case status
        case leaveTypes = "leave_types"
    }
}

struct LeaveType: Decodable {
    let id: Int
    let name: String
    let requestUnit: String
    let requiresAllocation: String
    let remainingBalance: String?
    let originalBalance: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case requestUnit = "request_unit"
        case requiresAllocation = "requires_allocation"
        case remainingBalance = "remaining_balance"
        case originalBalance = "original_balance"
    }
}

