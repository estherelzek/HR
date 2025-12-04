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
        let defaultURL = "https://ahmedelzupeir-androidapp21.odoo.com"
        if let saved = UserDefaults.standard.baseURL, !saved.isEmpty {
            if saved.hasSuffix("/") {
                return String(saved.dropLast())
            }
            return saved
        }
        return defaultURL
    }
    
    case validateCompany(apiKey: String, companyId: String, email: String, password: String)
    case employeeAttendance(action: String, token: String, lat: String? = nil, lng: String? = nil, action_time: String? = nil)
    case requestTimeOff(token: String, action: String)
    case leaveDuration(token: String, leaveTypeId: Int, requestDateFrom: String, requestDateTo: String, requestDateFromPeriod: String, requestUnitHalf: Bool, requestHourFrom: String?, requestHourTo: String?, requestUnitHours: Bool)
    case submitTimeOffRequest(token: String, leaveTypeId: Int, action: String, requestDateFrom: String, requestDateTo: String, requestDateFromPeriod: String, requestUnitHalf: Bool, hourFrom: String?, hourTo: String?) // ✅ NEW
    case getEmployeeTimeOffs(token: String , action: String)
    case unlinkDraftAnnualLeaves(token: String ,action: String , leaveId: Int)
    case getServerTime(token: String,action: String)
    case generateToken(employee_token: String , company_id : String , api_key : String)
    case offlineAttendance(token: String, attendanceLogs: [[String: Any]])
    case sendMobileToken(employeeToken: String, mobileToken: String)


    var path: String {
        switch self {
        case .validateCompany:
            return "/api/validate_company"
         //   return "/api/employee/authenticate"
        case .employeeAttendance:
            return "/api/employee_attendance"
        case .requestTimeOff:
            return "/api/request_time_off"
        case .leaveDuration:
            return "/api/leave/duration"
        case .submitTimeOffRequest:
            return "/api/request_time_off"
        case .getEmployeeTimeOffs:
            return "/api/employee_time_off"
        case .unlinkDraftAnnualLeaves:
            return "/api/request_time_off"
        case .getServerTime:
            return "/api/employee_attendance"
        case .generateToken:
            return "/api/employee/renew_token"
        case .offlineAttendance:
            return "/api/offline_attendance"
        case .sendMobileToken:
            return "/api/mobile_token"

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
            

        case let .employeeAttendance(action, token, lat, lng , action_time):
                   var payload: [String: Any] = [
                       "action": action,
                       "employee_token": token,
                       "action_time": action_time
                   ]
            
                   if let lat = lat, let lng = lng {
                       payload["lat"] = lat
                       payload["lng"] = lng
                   }
    
            return try? JSONSerialization.data(withJSONObject: payload)
            
        case let .requestTimeOff(token, action):
            let payload: [String: Any] = [
                "employee_token": token,
                "action": action
            ]
            return try? JSONSerialization.data(withJSONObject: payload)
            
        case let .leaveDuration(token, leaveTypeId, requestDateFrom, requestDateTo, requestDateFromPeriod, requestUnitHalf, requestHourFrom, requestHourTo, requestUnitHours):
            var payload: [String: Any] = [
                "employee_token": token,
                "leave_type_id": leaveTypeId,
                "request_date_from": requestDateFrom,
                "request_date_to": requestDateTo,
                "request_date_from_period": requestDateFromPeriod,
                "request_unit_half": requestUnitHalf,
                "request_unit_hours": requestUnitHours
            ]
            if let requestHourFrom = requestHourFrom {
                payload["request_hour_from"] = requestHourFrom
            }
            if let requestHourTo = requestHourTo {
                payload["request_hour_to"] = requestHourTo
            }
            return try? JSONSerialization.data(withJSONObject: payload)
            
        case let .submitTimeOffRequest(token, leaveTypeId, action, requestDateFrom, requestDateTo, requestDateFromPeriod, requestUnitHalf, hourFrom, hourTo):
            var payload: [String: Any] = [
                "employee_token": token,
                "leave_type_id": leaveTypeId,
                "action": action,
                "request_date_from": requestDateFrom,
                "request_date_to": requestDateTo,
                "request_date_from_period": requestDateFromPeriod,
                "request_unit_half": requestUnitHalf
            ]
            if let hourFrom = hourFrom, !hourFrom.isEmpty {
                payload["request_hour_from"] = hourFrom
            }
            if let hourTo = hourTo, !hourTo.isEmpty {
                payload["request_hour_to"] = hourTo
            }
            return try? JSONSerialization.data(withJSONObject: payload)
            
        case .getEmployeeTimeOffs(token: let token, action: let action):
            let payload: [String: Any] = [
                "employee_token": token,
                "action": action
            ]
            return try? JSONSerialization.data(withJSONObject: payload)
            
        case .unlinkDraftAnnualLeaves(token: let token, action: let action, leaveId: let leaveId):
            let payload: [String: Any] = [
                "employee_token": token,
                "action": action,
                "leave_id": leaveId
            ]
            return try? JSONSerialization.data(withJSONObject: payload)
        case .getServerTime(token: let token, action: let action):
            let serverTime: [String: Any] = [
                "employee_token": token,
                "action": action
            ]
            return try? JSONSerialization.data(withJSONObject: serverTime)
            
        case .generateToken(employee_token: let employee_token , company_id: let company_id , api_key: let api_key):
            let generateToken: [String: Any] = [
                "employee_token": employee_token ,
                "company_id": company_id ,
                "api_key": api_key
            ]
            return try? JSONSerialization.data(withJSONObject: generateToken, options: [])
            
        case let .offlineAttendance(token, attendanceLogs):
            let payload: [String: Any] = [
                "jsonrpc": "2.0",
                "method": "call",
                "params": [
                    "employee_token": token,
                    "attendance_logs": attendanceLogs
                ],
                "id": 0
            ]
            return try? JSONSerialization.data(withJSONObject: payload, options: [])

        case let .sendMobileToken(employeeToken, mobileToken):
            let payload: [String: Any] = [
                "employee_token": employeeToken,
                "mobile_token": mobileToken
            ]
            return try? JSONSerialization.data(withJSONObject: payload)

        }
        
    
    }
}
