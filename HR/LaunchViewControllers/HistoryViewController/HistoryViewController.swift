//
//  HistoryViewController.swift
//  HR
//
//  Created by Esther Elzek on 26/02/2026.
//

import UIKit

class HistoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var sections: [HistorySection] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadHistory()
    }
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: "HistoryTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "HistoryTableViewCell")
        
        tableView.separatorStyle = .none
    }
    private func loadHistory() {
        let orders = HistoryManager.shared.orders
        
        let grouped = Dictionary(grouping: orders) { order in
            order.dateString   // example: "26 Feb 2026"
        }
        
        sections = grouped.map { HistorySection(date: $0.key, orders: $0.value) }
            .sorted { $0.date > $1.date } // newest first
        
        tableView.reloadData()
    }
}
extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return sections[section].orders.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "HistoryTableViewCell",
            for: indexPath
        ) as! HistoryTableViewCell
        
        let order = sections[indexPath.section].orders[indexPath.row]
        cell.configure(with: order)
        
        cell.onReorderTapped = { [weak self] in
            InvoiceManager.shared.loadOrder(order)
            self?.dismiss(animated: true)
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        return sections[section].date
    }
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel()
        label.text = sections[section].date
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .white
        label.backgroundColor = .clear
        
        return label
    }
}
