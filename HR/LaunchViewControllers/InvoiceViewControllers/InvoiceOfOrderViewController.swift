//
//  InvoiceOfOrderViewController.swift
//  HR
//
//  Created by Esther Elzek on 15/01/2026.
//

import UIKit

struct Order: Identifiable {
    let id: UUID
    var quantity: Int
    let name: String
    let price: Double
}

class InvoiceOfOrderViewController: UIViewController {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: Inspectablelabel!
    @IBOutlet weak var emailLabel: Inspectablelabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalLabel: Inspectablelabel!
    @IBOutlet weak var totalPriceLabel: Inspectablelabel!
    @IBOutlet weak var alertView: InspectableView!
    
    private var orders: [Order] = [
          Order(id: UUID(), quantity: 1, name: "Burger", price: 50),
          Order(id: UUID(), quantity: 2, name: "Pizza", price: 120),
          Order(id: UUID(), quantity: 1, name: "Fries", price: 30),
          Order(id: UUID(), quantity: 3, name: "Cola", price: 15),
          Order(id: UUID(), quantity: 1, name: "Burger", price: 50),
          Order(id: UUID(), quantity: 2, name: "Pizza", price: 120),
          Order(id: UUID(), quantity: 1, name: "Fries", price: 30),
          Order(id: UUID(), quantity: 3, name: "Cola", price: 15)
      ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setData()
        setupTableView()
        updateTotal()
        animateIn()
    }
    
    func setData(){
        var name = UserDefaults.standard.employeeName ?? "Name"
        var email = UserDefaults.standard.employeeEmail ?? "Email"
        
        nameLabel.text = name
        emailLabel.text = email
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
        let total = orders.reduce(0) {
            $0 + (Double($1.quantity) * $1.price)
        }
        totalPriceLabel.text = "\(total) EGP"
    }

}
extension InvoiceOfOrderViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
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
            self?.orders[indexPath.row].quantity += 1
            self?.updateTotal()
            tableView.reloadRows(at: [indexPath], with: .none)
        }

        cell.onDecrease = { [weak self] in
            guard order.quantity > 1 else { return }
            self?.orders[indexPath.row].quantity -= 1
            self?.updateTotal()
            tableView.reloadRows(at: [indexPath], with: .none)
        }

        return cell
    }
}
