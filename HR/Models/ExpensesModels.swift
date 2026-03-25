//
//  ExpensesModels.swift
//  HR
//
//  Created by Esther Elzek on 08/03/2026.
//

import Foundation
// MARK: - API Response Wrappers
struct JsonRPCResponse<T: Codable>: Codable {
    let jsonrpc: String
    let id: Int?
    let result: T
}

// MARK: - Analytic Accounts
struct AnalyticAccount: Codable, Identifiable {
    let id: Int
    let name: String
    let code: String
    let plan_id: Int
    let plan_name: String
    let company_id: Int?
    let company_name: String?
}

struct AnalyticAccountsResult: Codable {
    let status: String
    let message: String
    let count: Int
    let data: [AnalyticAccount]
}

// MARK: - Taxes
struct Tax: Codable, Identifiable {
    let id: Int
    let name: String
    let amount: Double
    let amount_type: String
    let description: String
    let company_id: Int?
    let company_name: String?
}

struct TaxesResult: Codable {
    let status: String
    let message: String
    let count: Int
    let data: [Tax]
}

// MARK: - Employee Expense
struct EmployeeExpense: Codable, Identifiable {
    let id: Int
    let name: String
    let employee: String
    let employee_id: Int
    let company: String
    let company_id: Int
    let product: String
    let product_id: Int
    let total_amount: Double
    let currency: String
    let date: String
    let state: String
    let sheet_id: Int?
    let sheet_name: String?
    let description: String
    let tax_amount: Double
    let draft_total_amount: String

    enum CodingKeys: String, CodingKey {
        case id, name, employee, employee_id, company, company_id, product, product_id
        case total_amount, currency, date, state, sheet_id, sheet_name, description
        case tax_amount, draft_total_amount
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        employee = try container.decode(String.self, forKey: .employee)
        employee_id = try container.decode(Int.self, forKey: .employee_id)
        company = try container.decode(String.self, forKey: .company)
        company_id = try container.decode(Int.self, forKey: .company_id)
        product = try container.decode(String.self, forKey: .product)
        product_id = try container.decode(Int.self, forKey: .product_id)
        total_amount = try container.decode(Double.self, forKey: .total_amount)
        currency = try container.decode(String.self, forKey: .currency)
        date = try container.decode(String.self, forKey: .date)
        state = try container.decode(String.self, forKey: .state)
        sheet_id = try container.decodeIfPresent(Int.self, forKey: .sheet_id)
        sheet_name = try container.decodeIfPresent(String.self, forKey: .sheet_name)
        description = try container.decode(String.self, forKey: .description)

        // Accept both number and string from backend
        if let value = try? container.decode(Double.self, forKey: .tax_amount) {
            tax_amount = value
        } else if let value = try? container.decode(String.self, forKey: .tax_amount),
                  let doubleValue = Double(value) {
            tax_amount = doubleValue
        } else {
            tax_amount = 0
        }

        draft_total_amount = (try? container.decode(String.self, forKey: .draft_total_amount)) ?? ""
    }
}
struct EmployeeExpensesResult: Codable {
    let status: String
    let message: String
    let count: Int
    let data: [EmployeeExpense]
}

// MARK: - Submit Expense Response
struct SubmitExpenseResponse: Codable {
    let status: String
    let message: String
    let sheet_id: Int?
    let state: String?
}

// MARK: - Expense Categories
struct ExpenseCategory: Codable, Identifiable {
    let id: Int
    let name: String
    let category: String
    let category_id: Int
    let description: String
    let default_code: String
    let uom: String
}

struct ExpenseCategoriesResult: Codable {
    let status: String
    let message: String
    let count: Int
    let data: [ExpenseCategory]
}

// MARK: - Create Expense
struct CreateExpenseRequest {
    let token: String
    let name: String
    let product_id: Int
    let total_amount: Double
    let date: String
    let description: String
    let analytic_distribution: [String: Int]
    let tax_ids: [Int]
}

struct ExpenseProduct: Codable {
    let id: Int
    let name: String
    let category: String
    let category_id: Int
}

struct AnalyticAccountInfo: Codable {
    let id: Int
    let name: String
    let code: String
    let percentage: Int
}

struct TaxInfo: Codable {
    let id: Int
    let name: String
    let amount: Double
    let amount_type: String
}

struct CreateExpenseResponseData: Codable {
    let status: String
    let message: String
    let expense_id: Int
    let name: String
    let state: String
    let total_amount: Double
    let currency: String
    let currency_symbol: String
    let date: String
    let description: String
    let employee_id: Int
    let employee_name: String
    let company_id: Int
    let company_name: String
    let product: ExpenseProduct
    let analytic_distribution: [String: Int]
    let analytic_accounts: [AnalyticAccountInfo]
    let taxes: [TaxInfo]
    let tax_total_percentage: Double
    let total_with_tax: Double
}

typealias CreateExpenseResponse = JsonRPCResponse<CreateExpenseResponseData>
// Add this to handle error responses
struct CreateExpenseErrorResponse: Codable {
    let status: String
    let message: String
}

// Update the response handler to handle both success and error
struct CreateExpenseResultData: Codable {
    let status: String
    let message: String
    let expense_id: Int?
    let name: String?
    let state: String?
    let total_amount: Double?
    let currency: String?
    let currency_symbol: String?
    let date: String?
    let description: String?
    let employee_id: Int?
    let employee_name: String?
    let company_id: Int?
    let company_name: String?
    let product: ExpenseProduct?
    let analytic_distribution: [String: Int]?
    let analytic_accounts: [AnalyticAccountInfo]?
    let taxes: [TaxInfo]?
    let tax_total_percentage: Double?
    let total_with_tax: Double?
}

typealias CreateExpenseResponseNew = JsonRPCResponse<CreateExpenseResultData>

struct Currency: Codable {
    let id: Int
    let name: String
    let symbol: String
    let currency_code: String
    let rate: Double
    let conversion_rate: Double
    let is_company_currency: Bool
}

struct CurrenciesResult: Codable {
    let status: String
    let message: String
    let count: Int
    let data: [Currency]
}

// MARK: - Expense Reports
struct ExpenseReportsResult: Codable {
    let status: String
    let data: [ExpenseReportSheet]
}

struct ExpenseReportSheet: Codable {
    let sheet_id: Int
    let name: String
    let employee: String
    let state: String
    let total_amount: Double
    let expenses: [ExpenseReportExpense]
}

struct ExpenseReportExpense: Codable {
    let id: Int
    let name: String
    let amount: Double
    let date: String
}

struct ReportListItem {
    let sheet_id: Int
    let sheet_name: String
    let employee: String
    let state: String
    let total_amount: Double
    let expense: ExpenseReportExpense
}


struct DeleteFailureItem: Codable {
    let id: Int
    let reason: String
}

struct DeletedItem: Codable {
    let id: Int
    let name: String?
}

enum DeletedIDs: Codable {
    case ids([Int])
    case objects([DeletedItem])
    case none

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let ids = try? container.decode([Int].self) {
            self = .ids(ids)
            return
        }

        if let objs = try? container.decode([DeletedItem].self) {
            self = .objects(objs)
            return
        }

        self = .none
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .ids(let ids):
            try container.encode(ids)
        case .objects(let objs):
            try container.encode(objs)
        case .none:
            try container.encode([Int]())
        }
    }

    var idList: [Int] {
        switch self {
        case .ids(let ids):
            return ids
        case .objects(let objs):
            return objs.map { $0.id }
        case .none:
            return []
        }
    }
}

struct DeleteExpenseResponse: Codable {
    let status: String
    let message: String?
    let deleted: DeletedIDs?
    let failed: [DeleteFailureItem]?
}

struct DeleteReportResponse: Codable {
    let status: String
    let message: String?
    let deleted: DeletedIDs?
    let failed: [DeleteFailureItem]?
}

