//
//  LoginResponse.swift
//  HR
//
//  Created by Esther Elzek on 24/08/2025.
//

import Foundation
import Foundation

// MARK: - Root Response
struct LoginResponse: Decodable {
    let jsonrpc: String?
    let id: String?
    let result: LoginResult?
}

// MARK: - Login Result
struct LoginResult: Decodable {
    let status: String
    let message: LoginMessageUnion?
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

// MARK: - Message Union (string or object)
enum LoginMessageUnion: Decodable {
    case text(String)
    case object(LoginMessage)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let str = try? container.decode(String.self) {
            self = .text(str)
            return
        }
        self = .object(try container.decode(LoginMessage.self))
    }

    var textValue: String? {
        if case .text(let s) = self { return s }
        return nil
    }

    var objectValue: LoginMessage? {
        if case .object(let o) = self { return o }
        return nil
    }
}

// MARK: - Login Message
struct LoginMessage: Decodable {
    let status: String
    let message: String
    let employeeData: EmployeeDataWrapper?
    let company: [Company]?

    enum CodingKeys: String, CodingKey {
        case status, message
        case employeeData = "employee_data"
        case company
    }
}

// MARK: - Employee Data Wrapper
struct EmployeeDataWrapper: Decodable {
    let success: Bool
    let employeeData: EmployeeData

    enum CodingKeys: String, CodingKey {
        case success
        case employeeData = "employee_data"
    }
}

// MARK: - Employee Data
struct EmployeeData: Codable {
    let id: Int
    let name: String
    let email: String
    let department: String?
    let allowedLocationIDs: [Int]
    let jobTitle: String?
    let isActive: Bool
    let employeeToken: String
    let tokenExpiry: String

    enum CodingKeys: String, CodingKey {
        case id, name, email, department
        case allowedLocationIDs = "allowed_locations_ids"
        case jobTitle = "job_title"
        case isActive = "is_active"
        case employeeToken = "employee_token"
        case tokenExpiry = "token_expiry"
    }
}

// MARK: - Company
struct Company: Decodable {
    let name: String?
    let address: Address?
}

// MARK: - Address
struct Address: Decodable {
    let id: Int?
    let street: String?
    let city: String?
    let zip: String?
    let country: String?
    let latitude: Double?
    let longitude: Double?
    let allowedDistance: Double?

    enum CodingKeys: String, CodingKey {
        case id, street, city, zip, country, latitude, longitude
        case allowedDistance = "allowed_distance"
    }
}

// MARK: - Allowed Location (for UserDefaults saving)
struct AllowedLocation: Codable {
    let id: Int
    let latitude: Double
    let longitude: Double
    let allowedDistance: Double
}

//// MARK: - EmployeeData
//struct EmployeeData: Decodable {
//    let id: Int?
//    let name: String?
//    let email: String?
//    let department: String?
//    let jobTitle: String?
//    let isActive: Bool?
//    let employeeToken: String?
//    let tokenExpiry: String?
//
//    enum CodingKeys: String, CodingKey {
//        case id, name, email, department
//        case jobTitle = "job_title"
//        case isActive = "is_active"
//        case employeeToken = "employee_token"
//        case tokenExpiry = "token_expiry"
//    }
//}
//
//// MARK: - Company
//struct Company: Decodable {
//    let name: String?
//    let address: Address?
//}
//
//// MARK: - Address
//struct Address: Decodable {
//    let id: Int?                 // ✅ Added Address ID
//    let street: String?
//    let city: String?
//    let zip: String?
//    let country: String?
//    let latitude: Double?
//    let longitude: Double?
//    let allowedDistance: Double?
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case street, city, zip, country
//        case latitude, longitude
//        case allowedDistance = "allowed_distance"
//    }
//}
//
//// MARK: - Allowed Location (used for saving)
//struct AllowedLocation: Codable {
//    let id: Int
//    let latitude: Double
//    let longitude: Double
//    let allowedDistance: Double
//}
