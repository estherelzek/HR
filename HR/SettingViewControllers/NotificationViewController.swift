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

    @IBOutlet weak var emptyImage: UIImageView!
    @IBOutlet weak var TitLeLabel: UILabel!
    @IBOutlet weak var niotificationTableView: UITableView!
    
    var items: [NotificationModel] = [] // Use NotificationModel now
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTexts()
        setupTableView()
        loadNotifications()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(newNotificationReceived),
            name: Notification.Name("NewNotificationSaved"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(self,selector: #selector(languageChanged),name: NSNotification.Name("LanguageChanged"),object: nil)
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
    
    @objc private func languageChanged() {
        setUpTexts()
    }
    private func setUpTexts() {
        
        // Title localization
        TitLeLabel.text = NSLocalizedString("notification_title", comment: "")
        
        // Language handling
        let isArabic = LanguageManager.shared.currentLanguage() == "ar"
        
        if isArabic {
            view.semanticContentAttribute = .forceRightToLeft
            niotificationTableView.semanticContentAttribute = .forceRightToLeft
            TitLeLabel.textAlignment = .right
        } else {
            view.semanticContentAttribute = .forceLeftToRight
            niotificationTableView.semanticContentAttribute = .forceLeftToRight
            TitLeLabel.textAlignment = .left
        }
        
        niotificationTableView.reloadData()
    }

    
    private func loadNotifications() {
        items = NotificationStore.shared.load().sorted { $0.date > $1.date }
        print("items: \(items.count)")
        if items.count == 0 {
            DispatchQueue.main.async {
                self.emptyImage.isHidden = false
            }
        } else {
            DispatchQueue.main.async {
                self.emptyImage.isHidden = true
                self.niotificationTableView.reloadData()
            }
        }
        
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

        if LanguageManager.shared.currentLanguage() == "ar" {
            dateFormatter.locale = Locale(identifier: "ar")
        } else {
            dateFormatter.locale = Locale(identifier: "en")
        }

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
