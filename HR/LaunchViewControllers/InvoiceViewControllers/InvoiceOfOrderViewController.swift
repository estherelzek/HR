//
//  InvoiceOfOrderViewController.swift
//  HR
//
//  Created by Esther Elzek on 15/01/2026.
//

import UIKit

class InvoiceOfOrderViewController: UIViewController {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: Inspectablelabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalLabel: Inspectablelabel!
    @IBOutlet weak var totalPriceLabel: Inspectablelabel!
    @IBOutlet weak var alertView: InspectableView!
    @IBOutlet weak var orderButton: InspectableButton!
    
    private var orders: [Order] {
        return InvoiceManager.shared.orders
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setData()
        setupTableView()
        updateTotal()
        animateIn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        updateTotal()
        updateOrderButtonState()
    }

    
    func setData(){
        var name = UserDefaults.standard.employeeName ?? "Name"
        var email = UserDefaults.standard.employeeEmail ?? "Email"
        
        nameLabel.text = name
      //  emailLabel.text = email
    }
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        let nib = UINib(nibName: "InvoiceOfOrderTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "InvoiceOfOrderTableViewCell")
    }

    @IBAction func orderButtonTapped(_ sender: Any) {
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        alertView.layer.cornerRadius = 16
    }
    
    private func animateIn() {
        alertView.transform = CGAffineTransform(translationX: 0, y: 300)
        alertView.alpha = 0
        
        UIView.animate(withDuration: 0.3) {
            self.alertView.transform = .identity
            self.alertView.alpha = 1

        }
    }
    
    private func animateOut(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.25, animations: {
            self.alertView.transform = CGAffineTransform(translationX: 0, y: 300)
            self.alertView.alpha = 0
            self.view.alpha = 0
        }) { _ in
            completion?()
        }
    }
    
    
    private func updateTotal() {
        let total = InvoiceManager.shared.totalPrice()
        totalPriceLabel.text = "\(total) EGP"
    }
    
    private func updateOrderButtonState() {
        guard let orderButton = orderButton else {
            print("orderButton is nil ❌")
            return
        }

        let isEmpty = orders.isEmpty
        let title = isEmpty ? "Order" : "Update"

        orderButton.setTitle(title, for: .normal)
        orderButton.isEnabled = !isEmpty
        orderButton.alpha = isEmpty ? 0.5 : 1.0
    }



}
extension InvoiceOfOrderViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    // Swipe to delete
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            InvoiceManager.shared.removeItem(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            updateTotal()
            updateOrderButtonState()
        }

    }


    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "InvoiceOfOrderTableViewCell",
            for: indexPath
        ) as! InvoiceOfOrderTableViewCell

        let order = orders[indexPath.row]
        cell.configure(with: order)
        
        cell.onIncrease = { [weak self] in
            InvoiceManager.shared.increaseQuantity(at: indexPath.row)
            self?.updateTotal()
            self?.updateOrderButtonState()
            tableView.reloadRows(at: [indexPath], with: .none)
        }


        cell.onDecrease = { [weak self] in
            guard let self = self else { return }

            let currentQuantity = self.orders[indexPath.row].quantity
            InvoiceManager.shared.decreaseQuantity(at: indexPath.row)

            if currentQuantity - 1 <= 0 {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } else {
                tableView.reloadRows(at: [indexPath], with: .none)
            }

            self.updateTotal()
            self.updateOrderButtonState()
        }
        return cell
    }
}
