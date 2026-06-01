//
//  ExpensesViewController.swift
//  HR
//
//  Created by Esther Elzek on 11/03/2026.
//

import UIKit
import SwiftUI

class ExpensesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var expensesLabelTitle: Inspectablelabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: InspectableTableView!
    @IBOutlet weak var NewButton: InspectableButton!
    @IBOutlet weak var ReportsButton: InspectableButton!

    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    private var actionMenuView: UIView?
    private var overlayView: UIView?
    private let expensesViewModel = ExpensesViewModel()
    private var expensesList: [EmployeeExpense] = []
    /// Keep the unfiltered list as fetched from server
    private var allExpensesList: [EmployeeExpense] = []
    private let refreshControl = UIRefreshControl()
    /// true = show ReportsButton, hide submitButton in cells
    /// false = hide ReportsButton, show submitButton in cells
    var isReportScenario: Bool = false
    private var currentFilters: FiltersData = .empty
    private var selectedExpenseIds = Set<Int>()
    private var isMultiSelectMode: Bool = false {
        didSet {
            selectedExpenseIds.removeAll()
            tableView.reloadData()
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocalization()
        setupTableView()
        // Setup search bar behavior
        searchBar.delegate = self
        searchBar.returnKeyType = .search
        searchBar.enablesReturnKeyAutomatically = false
        // Dismiss keyboard when tapping outside the search bar
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        // Allow touches to pass through so tableView and other controls still receive taps
        dismissTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissTap)
        loadExpenses()
       // ReportsButton.isHidden = !isReportScenario
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.rowHeight = 125
        tableView.estimatedRowHeight = 125
        tableView.register(
            UINib(nibName: "ExpensesTableViewCell", bundle: nil),
            forCellReuseIdentifier: "ExpensesTableViewCell"
        )
        // Pull to refresh
        refreshControl.addTarget(self, action: #selector(handlePullToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    private func loadExpenses(showLoader: Bool = true) {
        guard let token = UserDefaults.standard.string(forKey: "employeeToken") else {
            refreshControl.endRefreshing()
            return
        }

        if showLoader {
            self.showLoader()
        }

        expensesViewModel.fetchEmployeeExpenses(token: token) { [weak self] result in
            guard let self = self else { return }

            if showLoader {
                self.hideLoader()
            }
            self.refreshControl.endRefreshing()

            switch result {
            case .success(let expenses):
                self.allExpensesList = expenses
                self.expensesList = expenses
                // Update report scenario from saved flag
                self.isReportScenario = UserDefaults.standard.bool(forKey: "is_17_version")
                self.ReportsButton.isHidden = !self.isReportScenario
                self.tableView.reloadData()
            case .failure(let error):
                print("❌ Failed to load expenses: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Filter Presentation

    @IBAction func filterButtonTapped(_ sender: Any) {
        // Present the SwiftUI FiltersView as a bottom sheet
        let filtersView = FiltersView(initial: currentFilters, onApply: { [weak self] data in
            guard let self = self else { return }
            self.currentFilters = data
            self.applyFilters(data)
        }, onReset: { [weak self] _ in
            guard let self = self else { return }
            self.currentFilters = FiltersData.empty
            self.applyFilters(FiltersData.empty)
        })

        let host = UIHostingController(rootView: filtersView)
        host.modalPresentationStyle = .pageSheet
        if let sheet = host.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        present(host, animated: true)
    }

    private func applyFilters(_ filters: FiltersData) {
        // Compute filtered array and apply
        let filtered = filteredExpenses(from: filters)
        self.expensesList = filtered
        self.tableView.reloadData()
    }

    /// Returns a filtered expenses array from the master `allExpensesList` without mutating state.
    private func filteredExpenses(from filters: FiltersData) -> [EmployeeExpense] {
        var filtered = allExpensesList

        // Date filtering
        if filters.dateEnabled {
            let from = Calendar.current.startOfDay(for: filters.fromDate)
            // include full day for toDate
            let to = Calendar.current.date(byAdding: DateComponents(day: 1, second: -1), to: filters.toDate) ?? filters.toDate

            filtered = filtered.filter { expense in
                guard let ed = parseExpenseDate(expense.date) else { return false }
                return (ed >= from) && (ed <= to)
            }
        }

        // Status filtering
        if filters.statusEnabled, let sel = filters.selectedStatus, !sel.isEmpty {
            let target = sel.lowercased()
            filtered = filtered.filter { $0.state.lowercased() == target }
        }

        // Attachment filtering
        if filters.attachmentEnabled, let has = filters.hasAttachment {
            if has {
                filtered = filtered.filter { ($0.attachments?.isEmpty == false) || (($0.attachment_count ?? 0) > 0) }
            } else {
                filtered = filtered.filter { ($0.attachments?.isEmpty ?? true) && (($0.attachment_count ?? 0) == 0) }
            }
        }

        return filtered
    }

    private func parseExpenseDate(_ s: String) -> Date? {
        // Try several common formats
        let formats = ["dd-MM-yyyy", "dd/MM/yyyy", "yyyy-MM-dd", "yyyy/MM/dd", "dd-MM-yyyy HH:mm:ss", "yyyy-MM-dd'T'HH:mm:ss"]
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        for f in formats {
            formatter.dateFormat = f
            if let d = formatter.date(from: s) { return d }
        }
        return nil
    }

    // MARK: - SearchBar (search by name only)
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        // Start from the filtered results according to currentFilters, then apply name filter
        var base = filteredExpenses(from: currentFilters)

        if !trimmed.isEmpty {
            base = base.filter { $0.name.range(of: trimmed, options: .caseInsensitive) != nil }
        }

        self.expensesList = base
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        // restore filtered results
        self.expensesList = filteredExpenses(from: currentFilters)
        tableView.reloadData()
    }

    // MARK: - Actions
    @IBAction func newButtonTapped(_ sender: UIButton) {
        let vc = AddExpensesViewController(nibName: "AddExpensesViewController", bundle: nil)
        vc.presentationController?.delegate = self
        vc.onExpenseCreated = { [weak self] in
            self?.loadExpenses()
        }
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
            sheet.delegate = self
        }
        present(vc, animated: true)
    }

    @IBAction func reportsButtonTapped(_ sender: UIButton) {
        showActionMenu(
            button: sender,
            titles: [
                NSLocalizedString("create_report", comment: ""),
                NSLocalizedString("view_reports", comment: "")
            ],
            actions: [
                #selector(createReportTapped),
                #selector(viewReportsTapped)
            ]
        )
    }

    // MARK: - Trash Button (Multi-select delete)
    @IBAction func trashButtonTapped(_ sender: Any) {
        if !isMultiSelectMode {
            // Enter multi-select mode — inform user
            isMultiSelectMode = true
            showAlert(
                title: NSLocalizedString("expenses.multiSelectHint", comment: ""),
                message: NSLocalizedString("expenses.multiSelectHintMessage", comment: "")
            )
            return
        }

        guard !selectedExpenseIds.isEmpty else {
            isMultiSelectMode = false
            return
        }

        guard let token = UserDefaults.standard.string(forKey: "employeeToken") else { return }

        let count = selectedExpenseIds.count
        let alert = UIAlertController(
            title: NSLocalizedString("expenses.deleteTitle", comment: ""),
            message: String(format: NSLocalizedString("expenses.multiDeleteMessage", comment: ""), count),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(
            title: NSLocalizedString("common.cancel", comment: "Cancel"),
            style: .cancel
        ) { [weak self] _ in
            self?.isMultiSelectMode = false
        })

        alert.addAction(UIAlertAction(
            title: NSLocalizedString("common.delete", comment: "Delete"),
            style: .destructive
        ) { [weak self] _ in
            guard let self = self else { return }
            let idsToDelete = Array(self.selectedExpenseIds)

            self.showLoader()
            self.expensesViewModel.deleteExpense(token: token, expenseIds: idsToDelete) { result in
                self.hideLoader()
                switch result {
                case .success(let response):
                    let deletedIds = Set(response.deleted?.idList ?? [])
                    let failedItems = response.failed ?? []
                    self.expensesList.removeAll { deletedIds.contains($0.id) }
                    self.selectedExpenseIds.removeAll()
                    self.isMultiSelectMode = false
                    self.tableView.reloadData()
                    if !failedItems.isEmpty {
                        let reasons = failedItems.map { "• \($0.reason)" }.joined(separator: "\n")
                        self.showAlert(
                            title: NSLocalizedString("expenses.partialDeleteTitle", comment: ""),
                            message: String(
                                format: NSLocalizedString("expenses.partialDeleteMessage", comment: ""),
                                deletedIds.count,
                                failedItems.count
                            ) + "\n\n" + reasons
                        )
                    }

                case .failure(let error):
                    self.isMultiSelectMode = false
                    self.showAlert(
                        title: NSLocalizedString("expenses.error", comment: "Error"),
                        message: NSLocalizedString("expenses.deleteFailed", comment: "")
                    )
                    print("❌ Batch delete failed: \(error.localizedDescription)")
                }
            }
        })

        present(alert, animated: true)
    }
  
    @objc private func handlePullToRefresh() {
        loadExpenses(showLoader: false)
    }
    
    @objc func newExpenseTapped() {
        hideActionMenu()
        let vc = AddExpensesViewController(nibName: "AddExpensesViewController", bundle: nil)
        vc.presentationController?.delegate = self
        vc.onExpenseCreated = { [weak self] in
            self?.loadExpenses()
        }
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
            sheet.delegate = self
        }
        present(vc, animated: true)
    }

    @objc func createReportTapped() {
        hideActionMenu()
        let vc = CreateReportsViewController(nibName: "CreateReportsViewController", bundle: nil)
        let draftExpenses = expensesList.filter { $0.state.lowercased() == "draft" }
        vc.expenses = draftExpenses
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        present(vc, animated: true)
    }

    @objc func viewReportsTapped() {
        hideActionMenu()
        let vc = ReportsViewController(nibName: "ReportsViewController", bundle: nil)
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        present(vc, animated: true)
    }

    // MARK: - Localization
    private func setupLocalization() {
        expensesLabelTitle.text = NSLocalizedString("expenses_title", comment: "")
        NewButton.setTitle(NSLocalizedString("new_expenses", comment: ""), for: .normal)
        ReportsButton.setTitle(NSLocalizedString("reports", comment: ""), for: .normal)
        let isArabic = LanguageManager.shared.currentLanguage() == "ar"
        NewButton.contentHorizontalAlignment = isArabic ? .right : .left
        ReportsButton.contentHorizontalAlignment = isArabic ? .right : .left
    }

    // MARK: - Action Menu
    private func showActionMenu(button: UIView, titles: [String], actions: [Selector]) {
        if actionMenuView != nil {
            hideActionMenu()
            return
        }

        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = .clear
        view.addSubview(overlay)
        overlayView = overlay

        let tap = UITapGestureRecognizer(target: self, action: #selector(outsideTapped))
        overlay.addGestureRecognizer(tap)

        let width: CGFloat = 180
        let height: CGFloat = CGFloat(titles.count * 46)

        let menu = UIView()
        menu.backgroundColor = .black.withAlphaComponent(0.9)
        menu.layer.cornerRadius = 12
        menu.layer.shadowColor = UIColor.black.cgColor
        menu.layer.shadowOpacity = 0.15
        menu.layer.shadowRadius = 6
        menu.layer.shadowOffset = CGSize(width: 0, height: 4)

        let frame = button.superview?.convert(button.frame, to: view) ?? .zero
        menu.frame = CGRect(x: frame.midX - width / 2, y: frame.minY - height - 8, width: width, height: height)

        let isArabic = LanguageManager.shared.currentLanguage() == "ar"
        for i in 0..<titles.count {
            let btn = UIButton(type: .system)
            btn.frame = CGRect(x: 0, y: CGFloat(i) * 46, width: width, height: 46)
            btn.setTitle(titles[i], for: .normal)
            btn.tintColor = .white
            btn.contentHorizontalAlignment = isArabic ? .right : .left
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            btn.addTarget(self, action: actions[i], for: .touchUpInside)
            menu.addSubview(btn)
        }

        overlay.addSubview(menu)
        actionMenuView = menu
    }

    @objc private func outsideTapped() { hideActionMenu() }

    @objc private func dismissKeyboard() {
        // Resign any first responder (including the searchBar)
        view.endEditing(true)
    }

    private func hideActionMenu() {
        actionMenuView?.removeFromSuperview()
        actionMenuView = nil
        overlayView?.removeFromSuperview()
        overlayView = nil
    }
}

// MARK: - Sheet dismissed → reload
extension ExpensesViewController: UISheetPresentationControllerDelegate, UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if presentationController.presentedViewController is AddExpensesViewController {
            loadExpenses()
        }
    }
}

// MARK: - TableView
extension ExpensesViewController {

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        expensesList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ExpensesTableViewCell",
            for: indexPath
        ) as? ExpensesTableViewCell else {
            return UITableViewCell()
        }

        let expense = expensesList[indexPath.row]
        cell.configure(with: expense)
        cell.contentView.layoutMargins = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)

        // Pass scenario flag to cell
        cell.isReportScenario = self.isReportScenario

        // Submit button visibility and style (only when NOT report scenario)
        if !isReportScenario {
            let isDraft = expense.state.lowercased() == "draft"
            let isPending = expense.state.lowercased() == "submit" || expense.state.lowercased() == "submitted"

            cell.submitButton?.isHidden = !(isDraft || isPending)
            cell.setSubmitPendingStyle(isPending)
        }

        cell.onSubmitTapped = { [weak self] in
            guard let self = self else { return }

            // Don't resubmit pending/submitted
            let state = expense.state.lowercased()
            if state == "submit" || state == "submitted" { return }

            guard let token = UserDefaults.standard.string(forKey: "employeeToken") else {
                self.showAlert(
                    title: NSLocalizedString("expenses.error", comment: "Error"),
                    message: NSLocalizedString("expenses.tokenMissing", comment: "Token is missing")
                )
                return
            }
            // If we are in report scenario, submit the full report (sheet) instead
            if self.isReportScenario {
                // Need a sheet id to submit
                guard let sheetId = expense.sheet_id else {
                    self.showAlert(
                        title: NSLocalizedString("expenses.error", comment: "Error"),
                        message: NSLocalizedString("report.sheetIdMissing", comment: "Sheet id is missing")
                    )
                    return
                }

                self.showLoader()
                self.expensesViewModel.submitReport(token: token, sheetId: sheetId) { result in
                    self.hideLoader()
                    switch result {
                    case .success(let response):
                        if response.sheet_id == sheetId {
                            self.showAlert(
                                title: NSLocalizedString("expenses.success", comment: "Success"),
                                message: response.message
                            )
                            self.loadExpenses()
                        } else {
                            let reason = response.message
                            self.showAlert(
                                title: NSLocalizedString("expenses.error", comment: "Error"),
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
                            title: NSLocalizedString("expenses.error", comment: "Error"),
                            message: message
                        )
                    }
                }
            } else {
                self.showLoader()
                self.expensesViewModel.sendExpense(token: token, expenseId: expense.id) { result in
                    self.hideLoader()

                    switch result {
                    case .success(let response):
                        if ((response.submitted?.contains(where: { $0.id == expense.id })) != nil) {
                            self.showAlert(
                                title: NSLocalizedString("expenses.success", comment: "Success"),
                                message: response.message
                            )
                            self.loadExpenses()
                        } else {
                            let reason = response.failed?.first(where: { $0.id == expense.id })?.reason
                                ?? response.message
                            self.showAlert(
                                title: NSLocalizedString("expenses.error", comment: "Error"),
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
                            title: NSLocalizedString("expenses.error", comment: "Error"),
                            message: message
                        )
                    }
                }
            }
        }

        // Show circle select button only in multi-select mode
        cell.selectButton?.isHidden = !isMultiSelectMode

        if isMultiSelectMode {
            cell.isExpenseSelected = selectedExpenseIds.contains(expense.id)
            cell.onToggleSelection = { [weak self, weak cell, weak tableView] in
                guard let self = self,
                      let cell = cell,
                      let ip = tableView?.indexPath(for: cell) else { return }

                let e = self.expensesList[ip.row]
                if self.selectedExpenseIds.contains(e.id) {
                    self.selectedExpenseIds.remove(e.id)
                } else {
                    self.selectedExpenseIds.insert(e.id)
                }
                tableView?.reloadRows(at: [ip], with: .none)
            }
        } else {
            cell.isExpenseSelected = false
            cell.onToggleSelection = nil
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 125 }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let expense = expensesList[indexPath.row]

        // In multi-select mode — tap cell = toggle selection
        if isMultiSelectMode {
            if selectedExpenseIds.contains(expense.id) {
                selectedExpenseIds.remove(expense.id)
            } else {
                selectedExpenseIds.insert(expense.id)
            }
            tableView.reloadRows(at: [indexPath], with: .none)
            return
        }

        // Normal mode — tap cell = edit
        let state = expense.state.lowercased()
        guard state == "draft"  else {
            showAlert(
                title: NSLocalizedString("expenses.error", comment: "Error"),
                message: NSLocalizedString("expenses.cannotEditMessage", comment: "")
            )
            return
        }

        let vc = AddExpensesViewController(nibName: "AddExpensesViewController", bundle: nil)
        vc.expenseToEdit = expense
        print("expenseToEdit: \(expense)")
        vc.onExpenseUpdated = { [weak self] in self?.loadExpenses() }
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        present(vc, animated: true)
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard !isMultiSelectMode else { return UISwipeActionsConfiguration(actions: []) }

        let expense = expensesList[indexPath.row]
        let state = expense.state.lowercased()
        let isDeletable = state == "draft" || state == "submitted"

        let deleteTitle = NSLocalizedString("common.delete", comment: "Delete")
        let deleteAction = UIContextualAction(style: .destructive, title: deleteTitle) { [weak self] _, _, completion in
            guard let self = self else { completion(false); return }

            guard isDeletable else {
                self.showAlert(
                    title: NSLocalizedString("expenses.error", comment: "Error"),
                    message: NSLocalizedString("expense.cannotDeleteMessage", comment: "")
                )
                completion(false)
                return
            }

            let alert = UIAlertController(
                title: NSLocalizedString("expenses.deleteTitle", comment: ""),
                message: String(format: NSLocalizedString("expenses.deleteMessage", comment: ""), expense.name),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("common.cancel", comment: ""), style: .cancel) { _ in
                completion(false)
            })
            alert.addAction(UIAlertAction(title: deleteTitle, style: .destructive) { _ in
                guard let token = UserDefaults.standard.string(forKey: "employeeToken") else { completion(false); return }
                self.showLoader()
                self.expensesViewModel.deleteExpense(token: token, expenseIds: [expense.id]) { result in
                    self.hideLoader()
                    switch result {
                    case .success(let response):
                        let deletedIds = Set(response.deleted?.idList ?? [])
                        if deletedIds.contains(expense.id) {
                            self.expensesList.remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .automatic)
                            completion(true)
                        } else {
                            let reason = response.failed?.first(where: { $0.id == expense.id })?.reason
                                ?? response.message
                                ?? NSLocalizedString("expenses.deleteFailed", comment: "")
                            self.showAlert(title: NSLocalizedString("expenses.error", comment: ""), message: reason)
                            completion(false)
                        }
                    case .failure:
                        self.showAlert(
                            title: NSLocalizedString("expenses.error", comment: "Error"),
                            message: NSLocalizedString("expenses.deleteFailed", comment: "")
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
  
}
