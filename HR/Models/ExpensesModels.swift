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
}

struct EmployeeExpensesResult: Codable {
    let status: String
    let message: String
    let count: Int
    let data: [EmployeeExpense]
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
