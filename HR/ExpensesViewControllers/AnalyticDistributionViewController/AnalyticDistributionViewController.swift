//
//  AnalyticDistributionViewController.swift
//  HR
//
//  Created by Esther Elzek on 08/03/2026.
//

import UIKit

class AnalyticDistributionViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalPercentageLabel: UILabel!
    @IBOutlet weak var precentageTitleLabel: UILabel!
    @IBOutlet weak var addLineButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    // Data
    var analyticAccounts: [AnalyticAccount] = []
    var distributions: [(account: AnalyticAccount, percentage: Int)] = []
    var onDistributionsSaved: (([Int: Int]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupLocalization()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isBeingDismissed {
            var result: [Int: Int] = [:]
            for (account, percentage) in distributions {
                result[account.id] = percentage
            }

            onDistributionsSaved?(result)
        }
    }
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addLineButton.addTarget(self, action: #selector(addLineButtonTapped), for: .touchUpInside)
        addLineButton.setTitleColor(.systemBlue, for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        // ✅ Register the XIB
        tableView.register(
            UINib(nibName: "AnalyticDistributionCellTableViewCell", bundle: nil),
            forCellReuseIdentifier: "AnalyticDistributionCellTableViewCell"
        )
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
    }
    
    private func setupLocalization() {
        addLineButton.setTitle(NSLocalizedString("expenses.addLine", comment: "Add a Line"), for: .normal)
        addLineButton.tintColor = .systemBlue
        totalPercentageLabel.text = updateTotalPercentage()
        precentageTitleLabel.text = NSLocalizedString("expenses.percentage", comment: "Percentage title")
    }
    
    @objc private func addLineButtonTapped() {
        // Show picker to select analytic account
        let alert = UIAlertController(
            title: NSLocalizedString("expenses.selectAnalytic", comment: "Select Analytic Account"),
            message: nil,
            preferredStyle: .actionSheet
        )
        
        for account in analyticAccounts {
            // Skip if already added
            if !distributions.contains(where: { $0.account.id == account.id }) {
                alert.addAction(UIAlertAction(title: account.name, style: .default) { [weak self] _ in
                    self?.showPercentageInput(for: account)
                })
            }
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("common.cancel", comment: "Cancel"), style: .cancel))
        present(alert, animated: true)
    }
    
    private func showPercentageInput(for account: AnalyticAccount) {
        let alert = UIAlertController(
            title: NSLocalizedString("expenses.enterPercentage", comment: "Enter Percentage"),
            message: NSLocalizedString("expenses.percentageMessage", comment: "Enter percentage for this account"),
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "0-100"
            textField.keyboardType = .numberPad
            textField.text = "100"
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("common.cancel", comment: "Cancel"), style: .cancel))
        alert.addAction(UIAlertAction(title: NSLocalizedString("common.save", comment: "Save"), style: .default) { [weak self] _ in
            if let percentageText = alert.textFields?.first?.text,
               let percentage = Int(percentageText),
               percentage > 0 && percentage <= 100 {
                self?.distributions.append((account: account, percentage: percentage))
                self?.tableView.reloadData()
                self?.updateTotalPercentageLabel()
            } else {
                self?.showAlert(
                    title: NSLocalizedString("expenses.validationTitle", comment: "Validation"),
                    message: NSLocalizedString("expenses.percentageInvalid", comment: "Please enter a valid percentage (1-100)")
                )
            }
        })
        
        present(alert, animated: true)
    }
    
    private func updateTotalPercentage() -> String {
        let total = distributions.reduce(0) { $0 + $1.percentage }
        let statusColor = total == 100 ? "✅" : "⚠️"
        return "\(statusColor) \(NSLocalizedString("expenses.total", comment: "Total")): \(total)%"
    }
    
    private func updateTotalPercentageLabel() {
        totalPercentageLabel.text = updateTotalPercentage()
    }
    
    @objc private func doneButtonTapped() {
        let total = distributions.reduce(0) { $0 + $1.percentage }
        
        if total != 100 {
            showAlert(
                title: NSLocalizedString("expenses.validationTitle", comment: "Validation"),
                message: NSLocalizedString("expenses.percentageMustBe100", comment: "Total percentage must be 100%")
            )
            return
        }
        
        // Convert to dictionary and return
        var result: [Int: Int] = [:]
        for (account, percentage) in distributions {
            result[account.id] = percentage
        }
        
        onDistributionsSaved?(result)
        dismiss(animated: true)
    }
    
    @objc private func closeButtonTapped() {

        var result: [Int: Int] = [:]
        for (account, percentage) in distributions {
            result[account.id] = percentage
        }

        onDistributionsSaved?(result)

        dismiss(animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("common.ok", comment: "OK"), style: .default))
        present(alert, animated: true)
    }
    
   
}

extension AnalyticDistributionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return distributions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "AnalyticDistributionCellTableViewCell",
            for: indexPath
        ) as! AnalyticDistributionCellTableViewCell
        
        let (account, percentage) = distributions[indexPath.row]
        cell.configure(
            accountName: account.name,
            percentage: percentage,
            onDeleteTapped: { [weak self, weak tableView] in
                guard let self = self,
                      let index = tableView?.indexPath(for: cell)?.row else { return }

                self.distributions.remove(at: index)
                tableView?.reloadData()
                self.updateTotalPercentageLabel()
            },
            onPercentageChanged: { [weak self] newPercentage in
                self?.distributions[indexPath.row].percentage = newPercentage
                self?.updateTotalPercentageLabel()
            }
        )
        
        return cell
    }
}
