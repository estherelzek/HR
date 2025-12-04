//
//  TokenResultModel.swift
//  HR
//
//  Created by Esther Elzek on 02/12/2025.
//

import Foundation

struct MobileTokenResponse: Codable {
    let status: String
    let message: String
    let data: MobileTokenData?
}

struct MobileTokenData: Codable {
    let employeeID: Int
    let email: String
    let employeeName: String

    enum CodingKeys: String, CodingKey {
        case employeeID = "employee_id"
        case email
        case employeeName = "employee_name"
    }
}
