//
//  TokenRenewalRequest.swift
//  HR
//
//  Created by Esther Elzek on 28/10/2025.
//

import Foundation

// MARK: - Request Model
struct TokenRenewalRequest: Codable {
    let employeeToken: String
    let companyID: String
    let apiKey: String

    enum CodingKeys: String, CodingKey {
        case employeeToken = "employee_token"
        case companyID = "company_id"
        case apiKey = "api_key"
    }
}

// MARK: - Response Model
struct TokenRenewalResponse: Codable {
    let jsonrpc: String
    let id: String?
    let result: TokenRenewalResult
}

// MARK: - Result Model
struct TokenRenewalResult: Codable {
    let status: String
    let message: String
    let employeeID: Int
    let email: String
    let employeeName: String
    let newToken: String
    let creationDate: String
    let expiryDate: String

    enum CodingKeys: String, CodingKey {
        case status
        case message
        case employeeID = "employee_id"
        case email
        case employeeName = "employee_name"
        case newToken = "new_token"
        case creationDate = "creation_date"
        case expiryDate = "expiry_date"
    }
}
