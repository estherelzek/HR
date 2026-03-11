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

    @IBOutlet weak var selectAllButton: UIButton!
    @IBOutlet weak var filterBySuppliersLabel: UILabel!
    @IBOutlet weak var alertView: InspectableView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var discardButton: UIButton!
    @IBOutlet weak var applyButton: UIButton!
    
    var suppliers: [LunchSupplier] = []
    var selectedSupplierIds: [Int] = []
    var onSuppliersSelected: (([Int]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupBackgroundTap()
        setupLocalization()
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
    
    private func setupLocalization() {
        filterBySuppliersLabel.text = NSLocalizedString("categories.filterBySuppliers", comment: "Filter by suppliers label")
        selectAllButton.setTitle(NSLocalizedString("categories.selectAll", comment: "Select all button"), for: .normal)
        applyButton.setTitle(NSLocalizedString("categories.apply", comment: "Apply button"), for: .normal)
        discardButton.setTitle(NSLocalizedString("categories.discard", comment: "Discard button"), for: .normal)
        
        // Update text alignment based on language direction
        let isRTL = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
        filterBySuppliersLabel.textAlignment = isRTL ? .right : .left
    }
    
    @objc private func backgroundTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)

        // If tap is outside the popup (alertView)
        if !alertView.frame.contains(location) {
            dismiss(animated: true)
        }
    }

    @IBAction func applyButtonTapped(_ sender: Any) {
        onSuppliersSelected?(selectedSupplierIds)
        dismiss(animated: true)
    }
    
    @IBAction func discardButtonTapped(_ sender: Any) {
        selectedSupplierIds.removeAll()
        dismiss(animated: true)
    }
    
    @IBAction func selectAllButtonTapped(_ sender: Any) {
        // Toggle select all - if all are selected, deselect all; otherwise select all
        if selectedSupplierIds.count == suppliers.count {
            selectedSupplierIds.removeAll()
        } else {
            selectedSupplierIds = suppliers.map { $0.id }
        }
        tableView.reloadData()
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

        let supplier = suppliers[indexPath.row]
        let isSelected = selectedSupplierIds.contains(supplier.id)
        
        cell.configure(
            with: supplier,
            isSelected: isSelected,
            onSelectionChanged: { [weak self] in
                self?.toggleSupplierSelection(supplier.id)
            }
        )
        cell.selectionStyle = .none

        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        // Do nothing - only allow button clicks
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    private func toggleSupplierSelection(_ supplierId: Int) {
        if let index = selectedSupplierIds.firstIndex(of: supplierId) {
            selectedSupplierIds.remove(at: index)
        } else {
            selectedSupplierIds.append(supplierId)
        }
        tableView.reloadData()
    }
}
