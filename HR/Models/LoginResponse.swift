//
//  LoginResponse.swift
//  HR
//
//  Created by Esther Elzek on 24/08/2025.
//

import Foundation

// MARK: - LoginResponse
struct LoginResponse: Decodable {
    let jsonrpc: String?
    let id: String?
    let result: LoginResult?
}

// MARK: - LoginResult
struct LoginResult: Decodable {
    let status: String                 // "success" or "error"
    let message: LoginMessageUnion?    // string OR object
    let companyName: String?
    let licenseExpiryDate: String?
    let companyURL: String?

    enum CodingKeys: String, CodingKey {
        case status, message
        case companyName = "company_name"
        case licenseExpiryDate = "license_expiry_date"
        case companyURL = "company_url"
    }
}

// wrapper that can decode either String or Object
enum LoginMessageUnion: Decodable {
    case text(String)
    case object(LoginMessage)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let s = try? container.decode(String.self) {
            self = .text(s)
            return
        }
        let obj = try container.decode(LoginMessage.self)
        self = .object(obj)
    }

    var textValue: String? {
        switch self {
        case .text(let s): return s
        case .object(let o): return o.message
        }
    }

    var objectValue: LoginMessage? {
        if case .object(let o) = self { return o }
        return nil
    }
}

struct LoginMessage: Decodable {
    let status: String        // "success" or "error"
    let message: String
    let employeeData: EmployeeData?
    let company: [Company]?

    enum CodingKeys: String, CodingKey {
        case status, message
        case employeeData = "employee_data"
        case company
    }
}

struct EmployeeData: Decodable {
    let id: Int?
    let name: String?
    let email: String?
    let department: String?
    let jobTitle: String?
    let isActive: Bool?
    let employeeToken: String?
    let tokenExpiry: String?

    enum CodingKeys: String, CodingKey {
        case id, name, email, department
        case jobTitle = "job_title"
        case isActive = "is_active"
        case employeeToken = "employee_token"
        case tokenExpiry = "token_expiry"
    }
}

struct Company: Decodable {
    let name: String?
    let address: Address?
}

struct Address: Decodable {
    let street: String?
    let city: String?
    let zip: String?
    let country: String?
    let latitude: Double?
    let longitude: Double?
    let allowedDistance: Double?

    enum CodingKeys: String, CodingKey {
        case street, city, zip, country, latitude, longitude
        case allowedDistance = "allowed_distance"
    }
}
