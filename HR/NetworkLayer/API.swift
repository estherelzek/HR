//
//  API.swift
//  HR
//
//  Created by Esther Elzek on 24/08/2025.
//

import Foundation


enum API: Endpoint {

    // 🔹 Fallback URL if nothing is set yet
    private static let fallbackURL = "https://default-url.com"

    // 🔹 Always read/write through UserDefaults
    static var defaultBaseURL: String {
        get {
            // Use saved value if exists, otherwise fallback
            if let saved = UserDefaults.standard.string(forKey: "baseURL"), !saved.isEmpty {
                return saved.hasSuffix("/") ? String(saved.dropLast()) : saved
            }
            return fallbackURL
        }
        set {
            // Only update if not empty
            guard !newValue.isEmpty else { return }
            let sanitized = newValue.hasSuffix("/") ? String(newValue.dropLast()) : newValue
            UserDefaults.standard.set(sanitized, forKey: "baseURL")
        }
    }
    var actionType: String? {
        switch self {
        case let .employeeAttendance(action, _, _, _, _):
            return action  // Only keep check_in, check_out, status
        default:
            return nil     // Discard all other APIs
        }
    }

    // 🔹 Update baseURL from encrypted file
    static func updateDefaultBaseURL(_ url: String) {
        defaultBaseURL = url
        print("🌍 API baseURL updated:", defaultBaseURL)
    }

    // 🔹 HTTP method
    var method: HTTPMethod { .POST }

    // 🔹 Headers
    var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }

    // 🔹 Base URL for each endpoint
    var baseURL: String {
        switch self {
        // 🔐 Always use defaultBaseURL for these endpoints
        case .validateCompany, .generateToken, .sendMobileToken:
            return API.defaultBaseURL

        // 🌍 Other APIs
        default:
            return API.defaultBaseURL
        }
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
    case sendMobileToken(employeeToken: String, mobileToken: String, mobile_type: String)
    // MARK: - Lunch APIs
    case lunchProducts(
        token: String,
        locationId: Int?,
        categoryId: Int?,
        supplierId: Int?,
        search: String?
    )

    case lunchProductDetails(
        token: String,
        productId: Int
    )

    case lunchCategories(token: String)

    case lunchSuppliers(
        token: String,
        locationId: Int?
    )

    case lunchOrders(token: String, orders: [[String: Any]])
    case getAnalyticAccounts(token: String)
       case getTaxes(token: String)
       case getExpenseCategories(token: String)
       case createExpense(
           token: String,
           name: String,
           product_id: Int,
           total_amount: Double,
           date: String,
           description: String,
           analytic_distribution: [String: Int],
           tax_ids: [Int],
           payment_mode: String
       )
    case getCurrencies(token: String)
    case getEmployeeExpenses(token: String)
    case submitExpense(token: String, expense_id: Int , name: String)
    case getExpenseReports(token: String)
    case deleteExpense(token: String, expense_ids: [Int])
    case deleteReport(token: String, sheet_ids: [Int])
    case updateExpense(
        token: String,
        expense_id: Int,
        name: String,
        product_id: Int,
        total_amount: Double,
        date: String,
        description: String,
        currency_id: Int,
        analytic_distribution: [String: Int],
        tax_ids: [Int],
        payment_mode: String
    )
    case updateReport(
        token: String,
        sheet_id: Int,
        name: String,
        expense_ids: [Int],
        remove_expense_ids: [Int]
    )
    
    
    var path: String {
        switch self {
        case .validateCompany:
            return "/api/validate_company"//defaultURL
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
            return "/api/employee/renew_token"//defaultURL
        case .offlineAttendance:
            return "/api/offline_attendance"
        case .sendMobileToken:
            return "/api/mobile_token"//defaultURL
        case .lunchProducts:
            return "/api/lunch/products"

        case .lunchProductDetails(_, let productId):
            return "/api/lunch/product/\(productId)"

        case .lunchCategories:
            return "/api/lunch/categories"

        case .lunchSuppliers:
            return "/api/lunch/suppliers"
        case .lunchOrders:
            return "/api/lunch/orders"
        case .getAnalyticAccounts:
                   return "/api/expenses/analytic_accounts"
        case .getTaxes:
                   return "/api/expenses/taxes"
        case .getExpenseCategories:
                   return "/api/expenses/categories"
        case .createExpense:
                   return "/api/expenses/create"
        case .getCurrencies:
            return "/api/expenses/currencies"
        case .getEmployeeExpenses:
            return "/api/expenses/get"
        case .submitExpense:
            return "/api/expenses/submit"
        case .getExpenseReports:
            return "/api/expenses/report"
        case .deleteExpense:
            return "/api/expenses/delete"
        case .deleteReport:
            return "/api/expenses/delete_report"
        case .updateExpense:
            return "/api/expenses/edit"
        case .updateReport:
            return "/api/expenses/edit_report"
            
               default:
                   return ""
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

        case let .sendMobileToken(employeeToken, mobileToken, mobile_type):
            let payload: [String: Any] = [
                "employee_token": employeeToken,
                "mobile_token": mobileToken,
                "mobile_type": mobile_type
            ]
            return try? JSONSerialization.data(withJSONObject: payload)
            
            
        case let .lunchProducts(token, locationId, categoryId, supplierId, search):
            var payload: [String: Any] = [
                "token": token
            ]

            if let locationId = locationId {
                payload["location_id"] = locationId
            }
            if let categoryId = categoryId {
                payload["category_id"] = categoryId
            }
            if let supplierId = supplierId {
                payload["supplier_id"] = supplierId
            }
            if let search = search, !search.isEmpty {
                payload["search"] = search
            }

            return try? JSONSerialization.data(withJSONObject: payload)

        case let .lunchProductDetails(token, _):
            let payload: [String: Any] = [
                "token": token
            ]
            return try? JSONSerialization.data(withJSONObject: payload)
            
        case let .lunchCategories(token):
            let payload: [String: Any] = [
                "token": token
            ]
            return try? JSONSerialization.data(withJSONObject: payload)

        case let .lunchSuppliers(token, locationId):
            var payload: [String: Any] = [
                "token": token
            ]

            if let locationId = locationId {
                payload["location_id"] = locationId
            }

            return try? JSONSerialization.data(withJSONObject: payload)
            
            
        case let .lunchOrders(token, orders):

            let payload: [String: Any] = [
                "token": token,
                "orders": orders
            ]

            return try? JSONSerialization.data(withJSONObject: payload)
        case let .getAnalyticAccounts(token):
                   let payload: [String: Any] = [
                       "jsonrpc": "2.0",
                       "params": [
                           "token": token
                       ]
                   ]
                   return try? JSONSerialization.data(withJSONObject: payload)

               case let .getTaxes(token):
                   let payload: [String: Any] = [
                       "jsonrpc": "2.0",
                       "params": [
                           "token": token
                       ]
                   ]
                   return try? JSONSerialization.data(withJSONObject: payload)

               case let .getExpenseCategories(token):
                   let payload: [String: Any] = [
                       "jsonrpc": "2.0",
                       "params": [
                           "token": token
                       ]
                   ]
                   return try? JSONSerialization.data(withJSONObject: payload)

               case let .createExpense(token, name, product_id, total_amount, date, description, analytic_distribution, tax_ids,payment_mode):
                   let payload: [String: Any] = [
                       "jsonrpc": "2.0",
                       "params": [
                           "token": token,
                           "name": name,
                           "product_id": product_id,
                           "total_amount": total_amount,
                           "date": date,
                           "description": description,
                           "analytic_distribution": analytic_distribution,
                           "tax_ids": tax_ids,
                           "payment_mode": payment_mode
                       ]
                   ]
                   return try? JSONSerialization.data(withJSONObject: payload)
            
        case let .getCurrencies(token):
            let payload: [String: Any] = [
                "jsonrpc": "2.0",
                "params": [
                    "token": token
                ]
            ]
            return try? JSONSerialization.data(withJSONObject: payload)

        case let .getEmployeeExpenses(token):
            let payload: [String: Any] = [
                "jsonrpc": "2.0",
                "params": [
                    "token": token
                ]
            ]
            return try? JSONSerialization.data(withJSONObject: payload)

        case let .submitExpense(token, expense_id , name):
            let payload: [String: Any] = [
                "jsonrpc": "2.0",
                "params": [
                    "token": token,
                    "expense_id": expense_id,
                    "name": name
                ]
            ]
            return try? JSONSerialization.data(withJSONObject: payload)
            
        case let .getExpenseReports(token):
            let payload: [String: Any] = [
                "jsonrpc": "2.0",
                "params": [
                    "token": token
                ]
            ]
            return try? JSONSerialization.data(withJSONObject: payload)
            
        case let .deleteExpense(token, expense_ids):
            let expenseValue: Any = expense_ids.count == 1 ? expense_ids[0] : expense_ids
            let payload: [String: Any] = [
                "jsonrpc": "2.0",
                "method": "call",
                "params": [
                    "expense_id": expenseValue,
                    "token": token
                ]
            ]
            return try? JSONSerialization.data(withJSONObject: payload)

        case let .deleteReport(token, sheet_ids):
            let sheetValue: Any = sheet_ids.count == 1 ? sheet_ids[0] : sheet_ids
            let payload: [String: Any] = [
                "jsonrpc": "2.0",
                "method": "call",
                "params": [
                    "sheet_id": sheetValue,
                    "token": token
                ]
            ]
            return try? JSONSerialization.data(withJSONObject: payload)

        case let .updateExpense(token, expense_id, name, product_id, total_amount, date, description, currency_id, analytic_distribution, tax_ids, payment_mode):
            let payload: [String: Any] = [
                "jsonrpc": "2.0",
                "method": "call",
                "params": [
                    "token": token,
                    "expense_id": expense_id,
                    "name": name,
                    "product_id": product_id,
                    "total_amount": total_amount,
                    "date": date,
                    "description": description,
                    "currency_id": currency_id,
                    "analytic_distribution": analytic_distribution,
                    "tax_ids": tax_ids,
                    "payment_mode": payment_mode
                ]
            ]
            
            return try? JSONSerialization.data(withJSONObject: payload)

        case let .updateReport(token, sheet_id, name, expense_ids, remove_expense_ids):
            let payload: [String: Any] = [
                "jsonrpc": "2.0",
                "method": "call",
                "params": [
                    "token": token,
                    "sheet_id": sheet_id,
                    "name": name,
                    "expense_ids": expense_ids,
                    "remove_expense_ids": remove_expense_ids
                ]
            ]
            return try? JSONSerialization.data(withJSONObject: payload)
           
               default:
                   return nil
               }
           }
       }
