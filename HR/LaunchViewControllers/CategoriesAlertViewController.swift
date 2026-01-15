//
//  CategoriesAlertViewController.swift
//  HR
//
//  Created by Esther Elzek on 15/01/2026.
//

import UIKit

import UIKit

struct Category: Identifiable {
    var id: UUID = UUID()
    var name: String
}

class CategoriesAlertViewController: UIViewController {

    @IBOutlet weak var alertView: InspectableView!
    @IBOutlet weak var tableView: UITableView!

    private let categories: [Category] = [
        Category(name: "Burgers"),
        Category(name: "Pizza"),
        Category(name: "Drinks"),
        Category(name: "Desserts"),
        Category(name: "Sandwiches")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
}

extension CategoriesAlertViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "CategoryCell",
            for: indexPath
        )

        cell.textLabel?.text = categories[indexPath.row].name
        cell.selectionStyle = .none
        return cell
    }
}
