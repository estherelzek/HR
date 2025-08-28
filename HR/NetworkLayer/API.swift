//
//  API.swift
//  HR
//
//  Created by Esther Elzek on 24/08/2025.
//

import Foundation

enum API: Endpoint {
    
    var method: HTTPMethod { .POST }

    var headers: [String : String] {
        [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
    var baseURL: String {
        let defaultURL = "https://ahmedelzupeir-androidapp2.odoo.com"
        if let saved = UserDefaults.standard.baseURL, !saved.isEmpty {
            if saved.hasSuffix("/") {
                return String(saved.dropLast())
            }
            return saved
        }
        return defaultURL
    }
    
    case validateCompany(apiKey: String, companyId: String, email: String, password: String)
    case employeeAttendance(action: String, token: String)
    case requestTimeOff(token: String, action: String)
    case leaveDuration(token: String,leaveTypeId: Int,requestDateFrom: String,requestDateTo: String,requestDateFromPeriod: String,requestUnitHalf: Bool,requestHourFrom: String?,requestHourTo: String?,requestUnitHours: Bool)


    var path: String {
        switch self {
        case .validateCompany:
            return "/api/validate_company"
        case .employeeAttendance:
            return "/api/employee_attendance"
        case .requestTimeOff:
            return "/api/request_time_off"
        case .leaveDuration:
            return "/api/leave/duration"
        }
    }

    var body: Data? {
        switch self {
        case let .validateCompany(apiKey, companyId, email, password):
            let payload: [String: Any] = [
                "api_key": apiKey,
                "company_id": companyId,
                "email": email,
                "password": password
            ]
            return try? JSONSerialization.data(withJSONObject: payload)

        case let .employeeAttendance(action, token):
            let payload: [String: Any] = [
                "params": [
                    "employee_token": token,
                    "action": action
                ]
            ]
            return try? JSONSerialization.data(withJSONObject: payload)

        case let .requestTimeOff(token, action):
            let payload: [String: Any] = [
                "employee_token": token,
                "action": action
            ]
            return try? JSONSerialization.data(withJSONObject: payload)
            
        case let .leaveDuration(
            token,
            leaveTypeId,
            requestDateFrom,
            requestDateTo,
            requestDateFromPeriod,
            requestUnitHalf,
            requestHourFrom,
            requestHourTo,
            requestUnitHours
        ):
            var payload: [String: Any] = [
                "employee_token": token,
                "leave_type_id": leaveTypeId,
                "request_date_from": requestDateFrom,
                "request_date_to": requestDateTo,
                "request_date_from_period": requestDateFromPeriod,
                "request_unit_half": requestUnitHalf ? true : false,
                "request_unit_hours": requestUnitHours ? true : false,
            ]

            if let requestHourFrom = requestHourFrom {
                payload["request_hour_from"] = requestHourFrom
            }
            if let requestHourTo = requestHourTo {
                payload["request_hour_to"] = requestHourTo
            }

            return try? JSONSerialization.data(withJSONObject: payload)

        }
    }
}
