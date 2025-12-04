//
//  LoginResponse.swift
//  HR
//
//  Created by Esther Elzek on 24/08/2025.
//

import Foundation

// MARK: - LoginResponse
// MARK: - LoginResponse
// MARK: - EmployeeData
struct EmployeeData: Decodable {
    let id: Int?
    let name: String?
    let email: String?
    let department: String?
    let companyId: Int?           // ✅ Add company_id
    let jobTitle: String?
    let isActive: Bool?
    let employeeToken: String?
    let tokenExpiry: String?
    let allowedBranchIDs: [Int]?  // ✅ Branch IDs employee is allowed to check in

    enum CodingKeys: String, CodingKey {
        case id, name, email, department
        case companyId = "company_id"
        case jobTitle = "job_title"
        case isActive = "is_active"
        case employeeToken = "employee_token"
        case tokenExpiry = "token_expiry"
        case allowedBranchIDs = "allowed_branch_ids"  // assuming backend sends it
    }
}

// MARK: - Company
struct Company: Decodable {
    let name: String?
    let address: Address?
    let id: Int?    // Company id to map branches
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
        case id
        case street, city, zip, country
        case latitude, longitude
        case allowedDistance = "allowed_distance"
    }
}

// MARK: - AllowedLocation (for saving in UserDefaults)
struct AllowedLocation: Codable {
    let id: Int
    let latitude: Double
    let longitude: Double
    let allowedDistance: Double
}

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

// MARK: - LoginMessageUnion
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

// MARK: - LoginMessage
struct LoginMessage: Decodable {
    let status: String
    let message: String
    let employeeData: EmployeeData?
    let company: [Company]?

    enum CodingKeys: String, CodingKey {
        case status, message
        case employeeData = "employee_data"
        case company
    }
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
