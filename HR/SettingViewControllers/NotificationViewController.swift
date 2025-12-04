//
//  NotificationViewController.swift
//  HR
//
//  Created by Esther Elzek on 02/12/2025.
//

import UIKit

struct NotificationItem {
    var title: String
    var description: String
    var date: String
    var isChecked: Bool
}

class NotificationViewController: UIViewController {

    @IBOutlet weak var TitLeLabel: UILabel!
    @IBOutlet weak var niotificationTableView: UITableView!
    
    var items: [NotificationItem] = [
        NotificationItem(title: "New Update",
                         description: "A new version of the app is available.",
                         date: "Today",
                         isChecked: false),
        
        NotificationItem(title: "Security Alert",
                         description: "Your password was changed.",
                         date: "Yesterday",
                         isChecked: true)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TitLeLabel.text = "Notifications"
        setupTableView()
    }

    private func setupTableView() {
        niotificationTableView.delegate = self
        niotificationTableView.dataSource = self
        niotificationTableView.register(
            UINib(nibName: "NotificationTableViewCell", bundle: nil),
            forCellReuseIdentifier: "NotificationTableViewCell"
        )
        
        niotificationTableView.tableFooterView = UIView()
    }
    
    @objc private func toggleCheckmark(_ sender: UIButton) {
        let index = sender.tag
        items[index].isChecked.toggle()
        niotificationTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "NotificationTableViewCell",
            for: indexPath
        ) as? NotificationTableViewCell else {
            return UITableViewCell()
        }
        
        let item = items[indexPath.row]
        cell.configure(with: item)
        cell.checkButton.tag = indexPath.row
        cell.checkButton.addTarget(self,
                                   action: #selector(toggleCheckmark(_:)),
                                   for: .touchUpInside)
        
        return cell
    }
}
