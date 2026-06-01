//
//  ReportsViewController.swift
//  HR
//
//  Created by Esther Elzek on 18/03/2026.
//

import UIKit

//
//  ReportsViewController.swift
//  HR
//
//  Created by Esther Elzek on 18/03/2026.
//

class ReportsViewController: UIViewController {

    @IBOutlet weak var reportsTitleLabel: Inspectablelabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: InspectableTableView!
    @IBOutlet weak var filterButton: UIButton!
    private let expensesViewModel = ExpensesViewModel()
    private var allItems: [ReportListItem] = []
    private var filteredItems: [ReportListItem] = []
    // Raw sheets kept so we can reconstruct full sheet on tap
    private var allSheets: [ExpenseReportSheet] = []
    // All draft expenses fetched alongside reports — used to populate edit screen
    private var allDraftExpenses: [EmployeeExpense] = []
    // Guard against concurrent loadReports() calls
    private var isLoadingReports = false
    private var selectedStatusFilter: String?
    private var selectedDateFilter: Date?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupFilterMenu()
        loadReports()
    }
    
    private func setupFilterMenu() {

        let allAction = UIAction(
            title: NSLocalizedString("filter.all", comment: "All statuses")
        ) { [weak self] _ in
            self?.selectedStatusFilter = nil
            self?.applyFilters()
        }

        let draftAction = UIAction(
            title: NSLocalizedString("status.draft", comment: "Draft")
        ) { [weak self] _ in
            self?.selectedStatusFilter = "draft"
            self?.applyFilters()
        }

        let submitAction = UIAction(
            title: NSLocalizedString("status.submitted", comment: "Submitted")
        ) { [weak self] _ in
            self?.selectedStatusFilter = "submit"
            self?.applyFilters()
        }

        let approvedAction = UIAction(
            title: NSLocalizedString("status.approved", comment: "Approved")
        ) { [weak self] _ in
            self?.selectedStatusFilter = "approved"
            self?.applyFilters()
        }

        let refusedAction = UIAction(
            title: NSLocalizedString("status.refused", comment: "Refused")
        ) { [weak self] _ in
            self?.selectedStatusFilter = "refused"
            self?.applyFilters()
        }

        let resetAction = UIAction(
            title: NSLocalizedString("common.reset", comment: "Reset"),
            image: UIImage(systemName: "arrow.counterclockwise")
        ) { [weak self] _ in
            self?.selectedStatusFilter = nil
            self?.searchBar.text = ""
            self?.applySearch("")
        }

        filterButton.menu = UIMenu(
            title: NSLocalizedString("filter.title", comment: "Filter"),
            children: [
                allAction,
                draftAction,
                submitAction,
                approvedAction,
                refusedAction,
                resetAction
            ]
        )

        filterButton.showsMenuAsPrimaryAction = true
    }
    
    private func applyFilters() {

        var result = allItems

        if let status = selectedStatusFilter {
            result = result.filter {
                $0.state.lowercased() == status.lowercased()
            }
        }

        let searchText = searchBar.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased() ?? ""

        if !searchText.isEmpty {
            result = result.filter {
                $0.sheet_name.lowercased().contains(searchText)
            }
        }

        filteredItems = result
        tableView.reloadData()
        updateSearchEmptyState()
    }
    
    private func setupUI() {
        reportsTitleLabel.text = NSLocalizedString("reports", comment: "")
        searchBar.delegate = self
        searchBar.returnKeyType = .search
        searchBar.enablesReturnKeyAutomatically = false
        searchBar.placeholder = NSLocalizedString("common.search", comment: "Search")
        hideKeyboardWhenTappedAround()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 125
        tableView.estimatedRowHeight = 125
        tableView.register(
            UINib(nibName: "ExpensesTableViewCell", bundle: nil),
            forCellReuseIdentifier: "ExpensesTableViewCell"
        )
    }

    private func loadReports() {
        guard !isLoadingReports else {
            print("⚠️ loadReports() skipped — already in progress")
            return
        }
        guard let token = UserDefaults.standard.string(forKey: "employeeToken") else { return }

        isLoadingReports = true
        showLoader()
        let group = DispatchGroup()

        group.enter()
        expensesViewModel.fetchExpenseReports(token: token) { [weak self] result in
            defer { group.leave() }
            guard let self = self else { return }
            switch result {
            case .success(let sheets):
                self.allSheets = sheets

                // One row per sheet (use first expense for display info)
                // This prevents duplicates when a sheet has multiple expenses
                var flattened: [ReportListItem] = []
                for sheet in sheets {
                    // Use first expense for cell display, or create a placeholder if empty
                    let representativeExpense = sheet.expenses.first ?? ExpenseReportExpense(
                        id: 0,
                        name: sheet.name,
                        amount: sheet.total_amount,
                        date: "",
                        payment_mode: nil,
                        payment_mode_label: nil
                    )
                    flattened.append(ReportListItem(
                        sheet_id: sheet.sheet_id,
                        sheet_name: sheet.name,
                        employee: sheet.employee,
                        state: sheet.state,
                        total_amount: sheet.total_amount,
                        expense: representativeExpense
                    ))
                }

                self.allItems = flattened
                self.filteredItems = flattened
                print("allItems count \(self.allItems.count)")
                print("filteredItems count \(self.filteredItems.count)")
            case .failure(let error):
                print("❌ Reports load error: \(error.localizedDescription)")
            }
        }

        group.enter()
        expensesViewModel.fetchEmployeeExpenses(token: token) { [weak self] result in
            defer { group.leave() }
            guard let self = self else { return }
            switch result {
            case .success(let expenses):
                // Keep only draft expenses for editing
                self.allDraftExpenses = expenses.filter { $0.state.lowercased() == "draft" }
            case .failure(let error):
                print("❌ Draft expenses load error: \(error.localizedDescription)")
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.isLoadingReports = false
            self.hideLoader()
            self.tableView.reloadData()
            self.updateSearchEmptyState()
        }
    }

    private func applySearch(_ text: String) {
        let q = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else {
            filteredItems = allItems
            tableView.reloadData()
            updateSearchEmptyState()
            return
        }

        filteredItems = allItems.filter {
            $0.sheet_name.lowercased().contains(q)
        }

        tableView.reloadData()
        updateSearchEmptyState()
    }

    private func updateSearchEmptyState() {
        if filteredItems.isEmpty {
            let label = UILabel()
            label.text = NSLocalizedString("common.noResults", comment: "No results")
            label.textAlignment = .center
            label.textColor = .gray
            tableView.backgroundView = label
        } else {
            tableView.backgroundView = nil
        }
    }
}

extension ReportsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ExpensesTableViewCell",
            for: indexPath
        ) as? ExpensesTableViewCell else {
            return UITableViewCell()
        }

        cell.configure(with: filteredItems[indexPath.row])
        let item = filteredItems[indexPath.row]
        cell.selectButton?.isHidden = true
        cell.isReportScenario = true

        // Show submit button only when sheet is draft or submit/submitted
        let state = item.state.lowercased()
        let isDraft = state == "draft"
        let isPending = state == "submit" || state == "submitted"
        cell.submitButton?.isHidden = !(isDraft || isPending)
        cell.setSubmitPendingStyle(isPending)

        cell.onSubmitTapped = { [weak self] in
            guard let self = self else { return }

            // Don't resubmit pending/submitted
            let state = item.state.lowercased()
            if state == "submit" || state == "submitted" { return }

            guard let token = UserDefaults.standard.string(forKey: "employeeToken") else {
                self.showAlert(
                    title: NSLocalizedString("expenses.error", comment: "Error"),
                    message: NSLocalizedString("expenses.tokenMissing", comment: "Token is missing")
                )
                return
            }

            self.showLoader()
            self.expensesViewModel.submitReport(token: token, sheetId: item.sheet_id) { result in
                self.hideLoader()
                switch result {
                case .success(let response):
                    if response.sheet_id == item.sheet_id {
                        self.showAlert(
                            title: NSLocalizedString("report.submittedSheetSuccess", comment: "Success"),
                            message: response.message
                        )
                        self.loadReports()
                    } else {
                        let reason = response.message
                        self.showAlert(
                            title: NSLocalizedString("report.submittedSheetFailed", comment: "Error"),
                            message: reason
                        )
                    }
                case .failure(let error):
                    let message: String
                    if case .requestFailed(let backendMessage) = error {
                        message = backendMessage
                    } else {
                        message = error.localizedDescription
                    }
                    self.showAlert(
                        title: NSLocalizedString("report.submittedSheetFailed", comment: "Error"),
                        message: message
                    )
                }
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteTitle = NSLocalizedString("common.delete", comment: "Delete")
        let deleteAction = UIContextualAction(style: .destructive, title: deleteTitle) { [weak self] _, _, completion in
            guard let self = self else {
                completion(false)
                return
            }

            let item = self.filteredItems[indexPath.row]
            let state = item.state.lowercased()
            let isDeletable = state == "draft" || state == "submit" || state == "submitted"

            // Block delete if state is not draft or submitted
            guard isDeletable else {
                self.showAlert(
                    title: NSLocalizedString("expenses.error", comment: "Error"),
                    message: NSLocalizedString("report.cannotDeleteMessage", comment: "")
                )
                completion(false)
                return
            }

            let alert = UIAlertController(
                title: NSLocalizedString("report.deleteTitle", comment: ""),
                message: String(format: NSLocalizedString("report.deleteMessage", comment: ""), item.sheet_name),
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(
                title: NSLocalizedString("common.cancel", comment: "Cancel"),
                style: .cancel
            ) { _ in
                completion(false)
            })

            alert.addAction(UIAlertAction(
                title: deleteTitle,
                style: .destructive
            ) { _ in
                guard let token = UserDefaults.standard.string(forKey: "employeeToken") else {
                    completion(false)
                    return
                }

                self.showLoader()
                self.expensesViewModel.deleteReport(token: token, sheetIds: [item.sheet_id]) { result in
                    self.hideLoader()

                    switch result {
                    case .success(let response):
                        let deletedIds = Set(response.deleted?.idList ?? [])
                        let sheetId = item.sheet_id

                        if deletedIds.contains(sheetId) {
                            self.allItems.removeAll { $0.sheet_id == sheetId }
                            self.filteredItems.removeAll { $0.sheet_id == sheetId }
                            tableView.reloadData()
                            self.updateSearchEmptyState()
                            completion(true)
                        } else {
                            let reason = response.failed?.first(where: { $0.id == sheetId })?.reason
                                ?? response.message
                                ?? NSLocalizedString("report.deleteFailed", comment: "")
                            self.showAlert(
                                title: NSLocalizedString("expenses.error", comment: "Error"),
                                message: NSLocalizedString("report.deleteFailed", comment: "")
                            )
                            completion(false)
                        }

                    case .failure(let error):
                        print("❌ Failed to delete report: \(error.localizedDescription)")
                        self.showAlert(
                            title: NSLocalizedString("expenses.error", comment: "Error"),
                            message: NSLocalizedString("report.deleteFailed", comment: "")
                        )
                        completion(false)
                    }
                }
            })

            self.present(alert, animated: true)
        }

        deleteAction.backgroundColor = UIColor.systemRed
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = filteredItems[indexPath.row]
        let state = item.state.lowercased()
        let isEditable = state == "draft" || state == "submit" || state == "submitted"

        guard isEditable else {
            showAlert(
                title: NSLocalizedString("expenses.error", comment: "Error"),
                message: NSLocalizedString("report.cannotEditMessage", comment: "")
            )
            return
        }

        guard let fullSheet = allSheets.first(where: { $0.sheet_id == item.sheet_id }) else { return }

        let reportExpenseIds = Set(fullSheet.expenses.map { $0.id })

        // Build combined list:
        // - All draft expenses (not yet in any report)
        // - Plus expenses already in THIS report (which may have state "submitted")
        // Avoid duplicates using Set on id
        let reportExpensesAsEmployeeExpense = fullSheet.expenses.map {
            EmployeeExpense.fromReportExpense($0, sheet: fullSheet)
        }
        var seen = Set<Int>()
        var combinedExpenses: [EmployeeExpense] = []
        for e in allDraftExpenses + reportExpensesAsEmployeeExpense {
            if seen.insert(e.id).inserted {
                combinedExpenses.append(e)
            }
        }

        let vc = CreateReportsViewController(nibName: "CreateReportsViewController", bundle: nil)
        vc.reportToEdit = fullSheet
        // Pass all available expenses
        vc.expenses = combinedExpenses
        // Pre-select only the ones already in the report
        vc.preselectedExpenseIds = reportExpenseIds
        vc.onReportUpdated = { [weak self] in
            self?.loadReports()
        }

        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }

        present(vc, animated: true)
    }

}

extension ReportsViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        applySearch("")
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applySearch(searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        applySearch(searchBar.text ?? "")
        searchBar.resignFirstResponder()
    }
}
