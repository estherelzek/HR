//
//  ReportsViewController.swift
//  HR
//
//  Created by Esther Elzek on 18/03/2026.
//

import UIKit

class ReportsViewController: UIViewController {

    @IBOutlet weak var reportsTitleLabel: Inspectablelabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: InspectableTableView!

    private let expensesViewModel = ExpensesViewModel()
    private var allItems: [ReportListItem] = []
    private var filteredItems: [ReportListItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadReports()
    }

    private func setupUI() {
        reportsTitleLabel.text = NSLocalizedString("reports", comment: "")

        searchBar.delegate = self
        searchBar.placeholder = NSLocalizedString("common.search", comment: "Search")

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 125
        tableView.estimatedRowHeight = 125
        tableView.register(UINib(nibName: "ExpensesTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "ExpensesTableViewCell")
    }

    private func loadReports() {
        guard let token = UserDefaults.standard.string(forKey: "employeeToken") else { return }

        expensesViewModel.fetchExpenseReports(token: token) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let sheets):
                let flattened = sheets.flatMap { sheet in
                    sheet.expenses.map { exp in
                        ReportListItem(
                            sheet_id: sheet.sheet_id,
                            sheet_name: sheet.name,
                            employee: sheet.employee,
                            state: sheet.state,
                            total_amount: sheet.total_amount,
                            expense: exp
                        )
                    }
                }

                self.allItems = flattened
                self.filteredItems = flattened
                self.tableView.reloadData()

            case .failure(let error):
                print("❌ Reports load error: \(error.localizedDescription)")
            }
        }
    }

    private func applySearch(_ text: String) {
        let q = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else {
            filteredItems = allItems
            tableView.reloadData()
            return
        }

        filteredItems = allItems.filter {
            $0.sheet_name.lowercased().contains(q) ||
            $0.employee.lowercased().contains(q) ||
            $0.expense.name.lowercased().contains(q) ||
            $0.state.lowercased().contains(q)
        }
        tableView.reloadData()
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

        // ✅ Fixed: use filteredItems directly
        cell.configure(with: filteredItems[indexPath.row])
        cell.selectButton?.isHidden = true
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

            // ✅ Confirmation alert
            let alert = UIAlertController(
                title: NSLocalizedString("report.deleteTitle", comment: ""),
                message: String(
                    format: NSLocalizedString("report.deleteMessage", comment: ""),
                    item.sheet_name
                ),
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(
                title: NSLocalizedString("common.cancel", comment: "Cancel"),
                style: .cancel
            ) { _ in
                completion(false)
            })

            alert.addAction(UIAlertAction(
                title: NSLocalizedString("common.delete", comment: "Delete"),
                style: .destructive
            ) { _ in
                guard let token = UserDefaults.standard.string(forKey: "employeeToken") else {
                    completion(false)
                    return
                }

                self.expensesViewModel.deleteReport(token: token, sheetIds: [item.sheet_id]) { result in
                    switch result {
                    case .success:
                        self.allItems.removeAll { $0.sheet_id == item.sheet_id }
                        self.filteredItems.removeAll { $0.sheet_id == item.sheet_id }
                        tableView.reloadData()
                        completion(true)
                    case .failure(let error):
                        print("❌ Failed to delete report: \(error.localizedDescription)")
                        completion(false)
                    }
                }
            })

            self.present(alert, animated: true)
        }

        deleteAction.backgroundColor = .systemRed
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
}

extension ReportsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applySearch(searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
