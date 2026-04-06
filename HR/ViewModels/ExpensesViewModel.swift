//
//  ExpensesViewModel.swift
//  HR
//
//  Created by Esther Elzek on 08/03/2026.
//

import Foundation

class ExpensesViewModel {
    // MARK: - Properties
    @Published var analyticAccounts: [AnalyticAccount] = []
    @Published var taxes: [Tax] = []
    @Published var expenseCategories: [ExpenseCategory] = []
    @Published var currencies: [Currency] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // For tracking selections
    var selectedAnalyticAccounts: [Int: Int] = [:] // id: percentage
    var selectedTaxIds: [Int] = []
    
    // MARK: - Fetch Analytic Accounts
    func fetchAnalyticAccounts(token: String, completion: @escaping (Result<[AnalyticAccount], APIError>) -> Void) {
        isLoading = true
        errorMessage = nil
        
        let endpoint = API.getAnalyticAccounts(token: token)
        
        NetworkManager.shared.requestDecodable(endpoint, as: JsonRPCResponse<AnalyticAccountsResult>.self) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let response):
                    self?.analyticAccounts = response.result.data
                    completion(.success(response.result.data))
                    print("✅ Analytic Accounts fetched: \(response.result.count)")
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    print("❌ Failed to fetch analytic accounts: \(error)")
                }
            }
        }
    }
    
    // MARK: - Fetch Taxes
    func fetchTaxes(token: String, completion: @escaping (Result<[Tax], APIError>) -> Void) {
        isLoading = true
        errorMessage = nil
        
        let endpoint = API.getTaxes(token: token)
        
        NetworkManager.shared.requestDecodable(endpoint, as: JsonRPCResponse<TaxesResult>.self) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let response):
                    self?.taxes = response.result.data
                    completion(.success(response.result.data))
                    print("✅ Taxes fetched: \(response.result.count)")
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    print("❌ Failed to fetch taxes: \(error)")
                }
            }
        }
    }
    
    // MARK: - Fetch Expense Categories
    func fetchExpenseCategories(token: String, completion: @escaping (Result<[ExpenseCategory], APIError>) -> Void) {
        isLoading = true
        errorMessage = nil
        
        let endpoint = API.getExpenseCategories(token: token)
        
        NetworkManager.shared.requestDecodable(endpoint, as: JsonRPCResponse<ExpenseCategoriesResult>.self) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let response):
                    self?.expenseCategories = response.result.data
                    completion(.success(response.result.data))
                    print("✅ Expense Categories fetched: \(response.result.count)")
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    print("❌ Failed to fetch expense categories: \(error)")
                }
            }
        }
    }
  
    // MARK: - Create Expense
    func createExpense(
        token: String,
        name: String,
        product_id: Int,
        total_amount: Double,
        date: String,
        description: String,
        analytic_distribution: [String: Int],
        tax_ids: [Int],
        payment_mode: String,
        completion: @escaping (Result<CreateExpenseResponseData, APIError>) -> Void
    ) {
        isLoading = true
        errorMessage = nil
        
        let endpoint = API.createExpense(
            token: token,
            name: name,
            product_id: product_id,
            total_amount: total_amount,
            date: date,
            description: description,
            analytic_distribution: analytic_distribution,
            tax_ids: tax_ids,
            payment_mode: payment_mode
        )
        
        NetworkManager.shared.requestDecodable(endpoint, as: CreateExpenseResponseNew.self) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let response):
                    // Check if backend returned an error status
                    if response.result.status == "error" {
                        // ✅ Return the backend error message directly
                        let backendError = response.result.message
                        self?.errorMessage = backendError
                        completion(.failure(.requestFailed(backendError)))
                        print("❌ Backend Error: \(backendError)")
                    } else if let expenseId = response.result.expense_id {
                        // Success case
                        let successResponse = CreateExpenseResponseData(
                            status: response.result.status,
                            message: response.result.message,
                            expense_id: expenseId,
                            name: response.result.name ?? "",
                            state: response.result.state ?? "",
                            total_amount: response.result.total_amount ?? 0,
                            currency: response.result.currency ?? "",
                            currency_symbol: response.result.currency_symbol ?? "",
                            date: response.result.date ?? "",
                            description: response.result.description ?? "",
                            employee_id: response.result.employee_id ?? 0,
                            employee_name: response.result.employee_name ?? "",
                            company_id: response.result.company_id ?? 0,
                            company_name: response.result.company_name ?? "",
                            product: response.result.product ?? ExpenseProduct(id: 0, name: "", category: "", category_id: 0),
                            analytic_distribution: response.result.analytic_distribution ?? [:],
                            analytic_accounts: response.result.analytic_accounts ?? [],
                            taxes: response.result.taxes ?? [],
                            tax_total_percentage: response.result.tax_total_percentage ?? 0,
                            total_with_tax: response.result.total_with_tax ?? 0
                        )
                        completion(.success(successResponse))
                        print("✅ Expense created: \(expenseId)")
                    } else {
                        // Missing expense_id but no error status
                        let unknownError = NSLocalizedString("expenses.unknownError", comment: "Unknown error occurred")
                        self?.errorMessage = unknownError
                        completion(.failure(.decodingError))
                        print("❌ Missing expense_id in response")
                    }
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    print("❌ Network Error: \(error)")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    func getAnalyticAccountName(by id: Int) -> String {
        return analyticAccounts.first(where: { $0.id == id })?.name ?? "Unknown"
    }
    
    func getTaxName(by id: Int) -> String {
        return taxes.first(where: { $0.id == id })?.name ?? "Unknown"
    }
    
    // MARK: - Fetch Employee Expenses
    func fetchEmployeeExpenses(token: String, completion: @escaping (Result<[EmployeeExpense], APIError>) -> Void) {
        isLoading = true
        errorMessage = nil

        let endpoint = API.getEmployeeExpenses(token: token)

        NetworkManager.shared.requestDecodable(endpoint, as: JsonRPCResponse<EmployeeExpensesResult>.self) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success(let response):
                    completion(.success(response.result.data))
                    print("✅ Employee Expenses fetched: \(response.result.count)")

                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    print("❌ Failed to fetch employee expenses: \(error)")
                }
            }
        }
    }

    // MARK: - Submit Expense
    func submitExpense(token: String, expenseId: Int , name: String , completion: @escaping (Result<SubmitExpenseResponse, APIError>) -> Void) {
        isLoading = true
        errorMessage = nil

        let endpoint = API.submitExpense(token: token, expense_id: expenseId , name: name)

        NetworkManager.shared.requestDecodable(endpoint, as: JsonRPCResponse<SubmitExpenseResponse>.self) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success(let response):
                    if response.result.status == "error" {
                        let msg = response.result.message
                        self?.errorMessage = msg
                        completion(.failure(.requestFailed(msg)))
                        print("❌ Submit Expense Error: \(msg)")
                    } else {
                        completion(.success(response.result))
                        print("✅ Expense \(expenseId) submitted. Sheet ID: \(response.result.sheet_id ?? -1)")
                    }

                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    print("❌ Failed to submit expense \(expenseId): \(error)")
                }
            }
        }
    }

    // MARK: - Fetch Currencies
    func fetchCurrencies(token: String, completion: @escaping (Result<[Currency], APIError>) -> Void) {
        
        isLoading = true
        errorMessage = nil
        
        let endpoint = API.getCurrencies(token: token)
        
        NetworkManager.shared.requestDecodable(endpoint, as: JsonRPCResponse<CurrenciesResult>.self) { [weak self] result in
            
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                    
                case .success(let response):
                    self?.currencies = response.result.data
                    completion(.success(response.result.data))
                    
                    print("✅ Currencies fetched: \(response.result.count)")
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    
                    print("❌ Failed to fetch currencies: \(error)")
                }
            }
        }
    }
    
    func fetchExpenseReports(token: String, completion: @escaping (Result<[ExpenseReportSheet], APIError>) -> Void) {
        isLoading = true
        errorMessage = nil

        let endpoint = API.getExpenseReports(token: token)

        // Keep using your shared decoder request (already logs in NetworkManager if enabled)
        NetworkManager.shared.requestDecodable(endpoint, as: JsonRPCResponse<ExpenseReportsResult>.self) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success(let response):
                    // Explicit raw-like debug from decoded object
                    if let rawData = try? JSONEncoder().encode(response),
                       let rawString = String(data: rawData, encoding: .utf8) {
                        print("📦 [RAW REPORT RESPONSE - DECODED]:\n\(rawString)")
                    }

                    completion(.success(response.result.data))
                    print("✅ Expense reports fetched: \(response.result.data.count)")

                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    print("❌ Failed to fetch expense reports: \(error)")
                }
            }
        }
    }
    
    func deleteExpense(token: String, expenseIds: [Int], completion: @escaping (Result<DeleteExpenseResponse, APIError>) -> Void) {
        isLoading = true
        errorMessage = nil

        let endpoint = API.deleteExpense(token: token, expense_ids: expenseIds)

        NetworkManager.shared.requestDecodable(endpoint, as: JsonRPCResponse<DeleteExpenseResponse>.self) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success(let response):
                    if response.result.status.lowercased() == "error" {
                        let msg = response.result.message ?? NSLocalizedString("expenses.deleteFailed", comment: "")
                        self?.errorMessage = msg
                        completion(.failure(.requestFailed(msg)))
                    } else {
                        completion(.success(response.result))
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                }
            }
        }
    }

    func deleteReport(token: String, sheetIds: [Int], completion: @escaping (Result<DeleteReportResponse, APIError>) -> Void) {
        isLoading = true
        errorMessage = nil

        let endpoint = API.deleteReport(token: token, sheet_ids: sheetIds)

        NetworkManager.shared.requestDecodable(endpoint, as: JsonRPCResponse<DeleteReportResponse>.self) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success(let response):
                    if response.result.status.lowercased() == "error" {
                        let msg = response.result.message ?? NSLocalizedString("report.deleteFailed", comment: "")
                        self?.errorMessage = msg
                        completion(.failure(.requestFailed(msg)))
                    } else {
                        completion(.success(response.result))
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Update Expense
    func updateExpense(
        token: String,
        expenseId: Int,
        name: String,
        product_id: Int,
        total_amount: Double,
        date: String,
        description: String,
        currency_id: Int,
        analytic_distribution: [String: Int],
        tax_ids: [Int],
        payment_mode: String,
        completion: @escaping (Result<UpdateExpenseResponse, APIError>) -> Void
    ) {
        isLoading = true
        errorMessage = nil

        let endpoint = API.updateExpense(
            token: token,
            expense_id: expenseId,
            name: name,
            product_id: product_id,
            total_amount: total_amount,
            date: date,
            description: description,
            currency_id: currency_id,
            analytic_distribution: analytic_distribution,
            tax_ids: tax_ids,
            payment_mode: payment_mode
        )

        NetworkManager.shared.requestDecodable(endpoint, as: JsonRPCResponse<UpdateExpenseResponse>.self) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    if response.result.status.lowercased() == "error" {
                        let msg = response.result.message ?? NSLocalizedString("expenses.updateFailed", comment: "")
                        self?.errorMessage = msg
                        completion(.failure(.requestFailed(msg)))
                    } else {
                        completion(.success(response.result))
                        print("✅ Expense \(expenseId) updated.")
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    print("❌ Failed to update expense \(expenseId): \(error)")
                }
            }
        }
    }
    
    // MARK: - Update Report
    func updateReport(
        token: String,
        sheetId: Int,
        name: String,
        expenseIds: [Int],
        removeExpenseIds: [Int] = [],
        completion: @escaping (Result<UpdateReportResponse, APIError>) -> Void
    ) {
        isLoading = true
        errorMessage = nil

        let endpoint = API.updateReport(
            token: token,
            sheet_id: sheetId,
            name: name,
            expense_ids: expenseIds,
            remove_expense_ids: removeExpenseIds
        )

        NetworkManager.shared.requestDecodable(endpoint, as: JsonRPCResponse<UpdateReportResponse>.self) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    if response.result.status.lowercased() == "error" {
                        let msg = response.result.message ?? NSLocalizedString("report.updateFailed", comment: "")
                        self?.errorMessage = msg
                        completion(.failure(.requestFailed(msg)))
                    } else {
                        completion(.success(response.result))
                        print("✅ Report \(sheetId) updated.")
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    print("❌ Failed to update report \(sheetId): \(error)")
                }
            }
        }
    }
}
