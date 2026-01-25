//
//  CategoriesPopUpViewController.swift
//  HR
//
//  Created by Esther Elzek on 20/01/2026.
//

import UIKit

struct Category: Identifiable {
    var id: UUID = UUID()
    var name: String
}

class CategoriesPopUpViewController: UIViewController {

    @IBOutlet weak var alertView: InspectableView!
    @IBOutlet weak var tableView: UITableView!

    var suppliers: [LunchSupplier] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupBackgroundTap()
        
    }
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        alertView.layer.cornerRadius = 16
    }
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()

        tableView.register(
            UINib(nibName: "CategoriesPopUpTableViewCell", bundle: nil),
            forCellReuseIdentifier: "CategoriesPopUpTableViewCell"
        )
    }
    private func setupBackgroundTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    @objc private func backgroundTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)

        // If tap is outside the popup (alertView)
        if !alertView.frame.contains(location) {
            dismiss(animated: true)
        }
    }

}


extension CategoriesPopUpViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suppliers.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "CategoriesPopUpTableViewCell",
            for: indexPath
        ) as? CategoriesPopUpTableViewCell else {
            return UITableViewCell()
        }

        let category = suppliers[indexPath.row]
        cell.categoryLabel.text = category.name
        cell.selectionStyle = .none

        return cell
    }

}
