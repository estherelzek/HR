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
    @IBOutlet weak var managerTitleLabel: UILabel!
    @IBOutlet weak var companyTitleLabel: Inspectablelabel!
    @IBOutlet weak var paidByTitleLabel: Inspectablelabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addExpenseToReportButton: InspectableButton!
    @IBOutlet weak var employeeTextField: InspectableTextField!
    @IBOutlet weak var managerTextField: InspectableTextField!
    @IBOutlet weak var companyTextField: InspectableTextField!
 
    @IBOutlet weak var saveReportButton: InspectableButton!
    @IBOutlet weak var employeeOrCompanySegment: UISegmentedControl!
    var expenses: [EmployeeExpense] = []
    private var selectedPaidBy: String = "employee"
    private var selectedExpenseIds = Set<Int>()
    private let expensesViewModel = ExpensesViewModel()

    // Convenience: selected expense objects
    private var selectedExpenses: [EmployeeExpense] {
        expenses.filter { selectedExpenseIds.contains($0.id) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocalization()
        prefillReportUserData()
        setupTableView()
        updateEmptyState()
        setupSegmentedControl()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateEmptyState()
    }

    private func updateEmptyState() {
        if expenses.isEmpty {
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
        createReportTitleLabel.text = NSLocalizedString("report.createTitle", comment: "Create Report")
        employeetitleLabel.text = NSLocalizedString("report.employee", comment: "Employee")
        managerTitleLabel.text = NSLocalizedString("report.manager", comment: "Manager")
        companyTitleLabel.text = NSLocalizedString("report.company", comment: "Company")
        paidByTitleLabel.text = NSLocalizedString("report.paidBy", comment: "Paid By")
        expenseReportSumaryTextField.placeholder = NSLocalizedString("report.summaryPlaceholder", comment: "")
        employeeTextField.placeholder = NSLocalizedString("report.employeePlaceholder", comment: "")
        managerTextField.placeholder = NSLocalizedString("report.managerPlaceholder", comment: "")
        companyTextField.placeholder = NSLocalizedString("report.companyPlaceholder", comment: "")
//        paidByTextField.placeholder = NSLocalizedString("report.paidByPlaceholder", comment: "")
        addExpenseToReportButton.setTitle(NSLocalizedString("report.addExpense", comment: ""), for: .normal)
        saveReportButton.setTitle(NSLocalizedString("report.save", comment: ""), for: .normal)

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
    }
    // MARK: - Button Action
    @IBAction func addexpenseToReportButtonTapped(_ sender: Any) {
        // Here you can present expense picker screen if needed.
        // For now, selection is done directly in this table.
        print("Add expense tapped")
    }

    @IBAction func saveReportButtonTapped(_ sender: Any) {
        guard !selectedExpenses.isEmpty else {
            showAlert(
                title: NSLocalizedString("common.validation", comment: "Validation"),
                message: NSLocalizedString("report.selectAtLeastOneExpense", comment: "Select at least one expense")
            )
            return
        }

        guard let token = UserDefaults.standard.string(forKey: "employeeToken") else {
            showAlert(
                title: NSLocalizedString("expenses.error", comment: "Error"),
                message: NSLocalizedString("expenses.tokenMissing", comment: "Token is missing")
            )
            return
        }

        let expenseIds = selectedExpenses.map { $0.id }
        print("✅ Submitting expense IDs:", expenseIds)

        var successCount = 0
        var failedIds: [Int] = []
        let group = DispatchGroup()

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
            if failedIds.isEmpty {
                self.showAlert(
                    title: NSLocalizedString("expenses.success", comment: "Success"),
                    message: String(
                        format: NSLocalizedString("report.submittedSuccess", comment: ""),
                        successCount
                    )
                )
            } else {
                self.showAlert(
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

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("common.ok", comment: "OK"), style: .default))
        present(alert, animated: true)
    }
    
    private func prefillReportUserData() {
        employeeTextField.text = UserDefaults.standard.employeeName
        companyTextField.text = UserDefaults.standard.companyName ?? ""
    }
}

extension CreateReportsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        expenses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ExpenseCellInReportTableViewCell",
            for: indexPath
        ) as? ExpenseCellInReportTableViewCell else {
            return UITableViewCell()
        }

        let expense = expenses[indexPath.row]
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
        let expense = expenses[indexPath.row]

        if selectedExpenseIds.contains(expense.id) {
            selectedExpenseIds.remove(expense.id)
        } else {
            selectedExpenseIds.insert(expense.id)
        }

        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
