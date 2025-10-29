//
//  OfflineAttendanceResponse.swift
//  HR
//
//  Created by Esther Elzek on 29/10/2025.
//

import Foundation

struct OfflineAttendanceResponse: Codable {
    let jsonrpc: String
    let id: Int?
    let result: OfflineAttendanceResult?
}

struct OfflineAttendanceResult: Codable {
    let status: String
    let message: String
}
