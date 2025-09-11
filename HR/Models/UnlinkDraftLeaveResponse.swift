//
//  UnlinkDraftLeaveResponse.swift
//  HR
//
//  Created by Esther Elzek on 09/09/2025.
//

import Foundation

struct UnlinkDraftLeaveResponse: Codable {
    let jsonrpc: String
    let id: String?
    let result: UnlinkResult
}

struct UnlinkResult: Codable {
    let status: String          // "success" or "error"
    let message: String
    let leaveId: Int?           // only present on success
    let errorCode: String?      // only present on error

    enum CodingKeys: String, CodingKey {
        case status
        case message
        case leaveId = "leave_id"
        case errorCode = "error_code"
    }
}
