//
//  ExpensesViewController.swift
//  HR
//
//  Created by Esther Elzek on 11/03/2026.
//

import UIKit

class ExpensesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
   
    
    @IBOutlet weak var expensesLabelTitle: Inspectablelabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: InspectableTableView!
    @IBOutlet weak var NewButton: InspectableButton!
    @IBOutlet weak var ReportsButton: InspectableButton!
    
    private var actionMenuView: UIView?
    private var overlayView: UIView?
    private let expensesViewModel = ExpensesViewModel()
    private var expensesList: [EmployeeExpense] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocalization()
        setupTableView()
        loadExpenses()
    }

    // MARK: - TableView Setup
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = UIColor.border
        tableView.register(
            UINib(nibName: "ExpensesTableViewCell", bundle: nil),
            forCellReuseIdentifier: "ExpensesTableViewCell"
        )
    }

    // MARK: - Load Expenses
    private func loadExpenses() {
        guard let token = UserDefaults.standard.string(forKey: "employeeToken") else { return }

        expensesViewModel.fetchEmployeeExpenses(token: token) { [weak self] result in
            switch result {
            case .success(let expenses):
                self?.expensesList = expenses
                self?.tableView.reloadData()
            case .failure(let error):
                print("❌ Failed to load expenses: \(error.localizedDescription)")
            }
        }
    }

    @IBAction func newButtonTapped(_ sender: UIButton) {
        
        showActionMenu(
            button: sender,
            titles: [
                NSLocalizedString("upload", comment: ""),
                NSLocalizedString("new_expenses", comment: "")
            ],
            actions: [
                #selector(uploadTapped),
                #selector(newExpenseTapped)
            ]
        )
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
    
    @objc func uploadTapped() {
        hideActionMenu()
        print("Upload tapped")
    }

    @objc func newExpenseTapped() {
        hideActionMenu()
        let historyVC = AddExpensesViewController(
            nibName: "AddExpensesViewController",
            bundle: nil
        )

        if let sheet = historyVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }

        present(historyVC, animated: true)
    }

    @objc func createReportTapped() {
        hideActionMenu()
        print("Create Report tapped")
    }

    @objc func viewReportsTapped() {
        hideActionMenu()
        print("View Reports tapped")
    }
    
    private func setupLocalization() {
        
        expensesLabelTitle.text = NSLocalizedString("expenses_title", comment: "")
        
        NewButton.setTitle(NSLocalizedString("new_expenses", comment: ""), for: .normal)
        
        ReportsButton.setTitle(NSLocalizedString("reports", comment: ""), for: .normal)
        
        let isArabic = LanguageManager.shared.currentLanguage() == "ar"
        
        NewButton.contentHorizontalAlignment = isArabic ? .right : .left
        ReportsButton.contentHorizontalAlignment = isArabic ? .right : .left
    }
    
    private func showActionMenu(button: UIView, titles: [String], actions: [Selector]) {
        
        if actionMenuView != nil {
            hideActionMenu()
            return
        }

        // Overlay (detect outside taps)
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

        menu.frame = CGRect(
            x: frame.midX - width/2,
            y: frame.minY - height - 8,
            width: width,
            height: height
        )

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
    @objc private func outsideTapped() {
        hideActionMenu()
    }
    
    private func hideActionMenu() {
        actionMenuView?.removeFromSuperview()
        actionMenuView = nil
        
        overlayView?.removeFromSuperview()
        overlayView = nil
    }
}

extension ExpensesViewController {
    
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return expensesList.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ExpensesTableViewCell",
                for: indexPath
            ) as? ExpensesTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: expensesList[indexPath.row])
            return cell
        }
    }

