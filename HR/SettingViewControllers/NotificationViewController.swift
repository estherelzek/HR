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
    
    var items: [NotificationModel] = [] // Use NotificationModel now
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TitLeLabel.text = "Notifications"
        setupTableView()
        loadNotifications()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(newNotificationReceived),
            name: Notification.Name("NewNotificationSaved"),
            object: nil
        )
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

    private func loadNotifications() {
        items = NotificationStore.shared.load().sorted { $0.date > $1.date }
        niotificationTableView.reloadData()
    }

    @objc private func newNotificationReceived() {
        loadNotifications()
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
        // Convert date to string for display
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        let dateString = dateFormatter.string(from: item.date)
        
        cell.configure(with: NotificationItem(
            title: item.title,
            description: item.message,
            date: dateString,
            isChecked: false
        ))
        
        return cell
    }
}
