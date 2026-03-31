//
//  CreateReportsViewController.swift
//  HR
//
//  Created by Esther Elzek on 12/03/2026.
//

import UIKit

class CreateReportsViewController: UIViewController {

    @IBOutlet weak var createReportTitleLabel: Inspectablelabel!
    @IBOutlet weak var reportInfoView: InspectableView!
    @IBOutlet weak var expenseReportSumaryTextField: InspectableTextField!
    @IBOutlet weak var employeetitleLabel: Inspectablelabel!
  //  @IBOutlet weak var managerTitleLabel: UILabel!
    @IBOutlet weak var companyTitleLabel: Inspectablelabel!
    @IBOutlet weak var paidByTitleLabel: Inspectablelabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addExpenseToReportButton: InspectableButton!
    @IBOutlet weak var employeeTextField: InspectableTextField!
   // @IBOutlet weak var managerTextField: InspectableTextField!
    @IBOutlet weak var companyTextField: InspectableTextField!
    @IBOutlet weak var saveReportButton: InspectableButton!
    @IBOutlet weak var employeeOrCompanySegment: UISegmentedControl!
    
    var expenses: [EmployeeExpense] = []
    var reportToEdit: ExpenseReportSheet?
    var onReportUpdated: (() -> Void)?
    var preselectedExpenseIds: Set<Int> = []
    private var selectedPaidBy: String = "employee"
    private var selectedExpenseIds = Set<Int>()
    private let expensesViewModel = ExpensesViewModel()
    private var isEditMode: Bool { reportToEdit != nil }
    private var selectedExpenses: [EmployeeExpense] {
        filteredExpenses.filter { selectedExpenseIds.contains($0.id)}
    }

    // Filter expenses by payment mode matching the selected Paid By mode
    private var filteredExpenses: [EmployeeExpense] {
        let targetPaymentMode: String? = selectedPaidBy == "company" ? "company_account" : "own_account"
        
        return expenses.filter { expense in
            // If expense has no payment_mode, include it (backward compat)
            guard let expensePaymentMode = expense.payment_mode else { return true }
            
            // Match expense payment_mode with report payment_mode
            return expensePaymentMode == targetPaymentMode
        }
        print("✅ Filtered expenses for Paid By '\(filteredExpenses)")
    }
   

    override func viewDidLoad() {
        print("expenses in create report: \(expenses) , \(expenses.count)")
        print("report to edit: \(String(describing: reportToEdit))")
        super.viewDidLoad()
        setupLocalization()
        prefillReportUserData()
        setupTableView()
        updateEmptyState()
        setupSegmentedControl()
        setupKeyboardDismissal()
        if let sheet = reportToEdit {
            prefillEditData(from: sheet)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateEmptyState()
    }

    private func updateEmptyState() {
        if filteredExpenses.isEmpty {
            let label = UILabel()
            label.text = NSLocalizedString("report.noDraftExpenses", comment: "")
            label.textAlignment = .center
            label.textColor = .gray
            tableView.backgroundView = label
        } else {
            tableView.backgroundView = nil
        }
    }

    // MARK: - Localization
    private func setupLocalization() {
        createReportTitleLabel.text = isEditMode
            ? NSLocalizedString("report.editTitle", comment: "Edit Report")
            : NSLocalizedString("report.createTitle", comment: "Create Report")

        saveReportButton.setTitle(
            isEditMode
                ? NSLocalizedString("common.update", comment: "Update")
                : NSLocalizedString("report.save", comment: "Save"),
            for: .normal
        )

        employeetitleLabel.text = NSLocalizedString("report.employee", comment: "Employee")
        companyTitleLabel.text = NSLocalizedString("report.company", comment: "Company")
        paidByTitleLabel.text = NSLocalizedString("report.paidBy", comment: "Paid By")
        expenseReportSumaryTextField.placeholder = NSLocalizedString("report.summaryPlaceholder", comment: "")
        employeeTextField.placeholder = NSLocalizedString("report.employeePlaceholder", comment: "")
        companyTextField.placeholder = NSLocalizedString("report.companyPlaceholder", comment: "")
        addExpenseToReportButton.setTitle(NSLocalizedString("report.addExpense", comment: ""), for: .normal)

        let isRTL = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
        view.semanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight
    }

    // MARK: - TableView Setup
    private func setupTableView() {
        guard tableView != nil else {
            print("❌ tableView IBOutlet is not connected in XIB")
            return
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.separatorColor = UIColor.border
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.allowsMultipleSelection = true
        let nib = UINib(nibName: "ExpenseCellInReportTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ExpenseCellInReportTableViewCell")
    }
    
    private func setupSegmentedControl() {
        employeeOrCompanySegment.removeAllSegments()
        employeeOrCompanySegment.insertSegment(
            withTitle: NSLocalizedString("expenses.employee", comment: "Employee"),
            at: 0,
            animated: false
        )
        employeeOrCompanySegment.insertSegment(
            withTitle: NSLocalizedString("expenses.company", comment: "Company"),
            at: 1,
            animated: false
        )
        employeeOrCompanySegment.selectedSegmentIndex = 0
        employeeOrCompanySegment.addTarget(
            self,
            action: #selector(segmentedControlChanged(_:)),
            for: .valueChanged
        )
    }
    
    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        selectedPaidBy = sender.selectedSegmentIndex == 0 ? "employee" : "company"
        print("✅ Paid By: \(selectedPaidBy)")
        // Reload table to show only matching payment_mode expenses
        tableView.reloadData()
        updateEmptyState()
    }
    // MARK: - Button Action
    @IBAction func addexpenseToReportButtonTapped(_ sender: Any) {
        // Here you can present expense picker screen if needed.
        // For now, selection is done directly in this table.
        print("Add expense tapped")
    }

    @IBAction func saveReportButtonTapped(_ sender: Any) {
        guard !selectedExpenses.isEmpty else {
            showReportAlert(
                title: NSLocalizedString("common.validation", comment: "Validation"),
                message: NSLocalizedString("report.selectAtLeastOneExpense", comment: "Select at least one expense")
            )
            return
        }

        guard let token = UserDefaults.standard.string(forKey: "employeeToken") else {
            showReportAlert(
                title: NSLocalizedString("expenses.error", comment: "Error"),
                message: NSLocalizedString("expenses.tokenMissing", comment: "Token is missing")
            )
            return
        }

        // MARK: Edit mode — call updateReport
        if let sheet = reportToEdit {
            let expenseIds = selectedExpenses.map { $0.id }
            let reportName = expenseReportSumaryTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? sheet.name

            showLoader()
            expensesViewModel.updateReport(
                token: token,
                sheetId: sheet.sheet_id,
                name: reportName,
                expenseIds: expenseIds
            ) { [weak self] result in
                guard let self = self else { return }
                self.hideLoader()
                switch result {
                case .success:
                    self.showReportAlert(
                        title: NSLocalizedString("expenses.success", comment: "Success"),
                        message: NSLocalizedString("report.updatedSuccessfully", comment: "Report updated successfully"),
                        onOK: { [weak self] in
                            self?.onReportUpdated?()
                            self?.dismiss(animated: true)
                        }
                    )
                case .failure(let error):
                    let message: String
                    if case .requestFailed(let backendMessage) = error {
                        message = backendMessage
                    } else {
                        message = NSLocalizedString("report.updateFailed", comment: "")
                    }
                    self.showReportAlert(
                        title: NSLocalizedString("expenses.error", comment: "Error"),
                        message: message
                    )
                }
            }
            return
        }

        // MARK: Create mode — batch submit expenses
        let expenseIds = selectedExpenses.map { $0.id }
        print("✅ Submitting expense IDs:", expenseIds)

        var successCount = 0
        var failedIds: [Int] = []
        let group = DispatchGroup()

        showLoader()
        for expenseId in expenseIds {
            group.enter()
            expensesViewModel.submitExpense(token: token, expenseId: expenseId) { result in
                switch result {
                case .success(let response):
                    print("✅ Expense \(expenseId) submitted — sheet: \(response.sheet_id ?? -1), state: \(response.state ?? "")")
                    successCount += 1
                case .failure(let error):
                    print("❌ Failed to submit expense \(expenseId): \(error.localizedDescription)")
                    failedIds.append(expenseId)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.hideLoader()
            if failedIds.isEmpty {
                self.showReportAlert(
                    title: NSLocalizedString("expenses.success", comment: "Success"),
                    message: String(format: NSLocalizedString("report.submittedSuccess", comment: ""), successCount),
                    onOK: { [weak self] in
                        self?.dismiss(animated: true)
                    }
                )
            } else {
                self.showReportAlert(
                    title: NSLocalizedString("expenses.error", comment: "Error"),
                    message: String(
                        format: NSLocalizedString("report.submittedPartial", comment: ""),
                        successCount,
                        failedIds.count
                    )
                )
            }
        }
    }

    private func showReportAlert(title: String, message: String, onOK: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("common.ok", comment: "OK"), style: .default) { _ in
            onOK?()
        })
        present(alert, animated: true)
    }
    
    private func prefillReportUserData() {
        employeeTextField.text = UserDefaults.standard.employeeName
        companyTextField.text = UserDefaults.standard.companyName ?? ""
    }

    // MARK: - Prefill for edit mode
    private func prefillEditData(from sheet: ExpenseReportSheet) {
        expenseReportSumaryTextField.text = sheet.name
        // Pre-select only expenses already belonging to this report
        selectedExpenseIds = preselectedExpenseIds.isEmpty
            ? Set(sheet.expenses.map { $0.id })
            : preselectedExpenseIds

        let reportPaymentMode = sheet.payment_mode_label?.lowercased()
        let expensePaymentMode = sheet.expenses.first?.payment_mode?.lowercased()
        let paymentModeLabel = sheet.expenses.first?.payment_mode_label?.lowercased()

        let isCompanyPaid: Bool = {
            if reportPaymentMode == "company_account" || reportPaymentMode == "company" {
                return true
            }
            if expensePaymentMode == "company_account" || expensePaymentMode == "company" {
                return true
            }
            if paymentModeLabel == "company" {
                return true
            }
            return false
        }()

        employeeOrCompanySegment.selectedSegmentIndex = isCompanyPaid ? 1 : 0
        selectedPaidBy = isCompanyPaid ? "company" : "employee"
    }
}

extension CreateReportsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        filteredExpenses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ExpenseCellInReportTableViewCell",
            for: indexPath
        ) as? ExpenseCellInReportTableViewCell else {
            return UITableViewCell()
        }

        let expense = filteredExpenses[indexPath.row]
        let selected = selectedExpenseIds.contains(expense.id)
        cell.configure(with: expense, isSelected: selected)

        cell.onToggleSelection = { [weak self, weak tableView] in
            guard let self = self else { return }
            if self.selectedExpenseIds.contains(expense.id) {
                self.selectedExpenseIds.remove(expense.id)
            } else {
                self.selectedExpenseIds.insert(expense.id)
            }
            tableView?.reloadRows(at: [indexPath], with: .none)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        let expense = filteredExpenses[indexPath.row]

        if selectedExpenseIds.contains(expense.id) {
            selectedExpenseIds.remove(expense.id)
        } else {
            selectedExpenseIds.insert(expense.id)
        }

        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    private func setupKeyboardDismissal() {
     let    tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
