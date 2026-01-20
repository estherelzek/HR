//
//  OrderAlertViewController.swift
//  HR
//
//  Created by Esther Elzek on 14/01/2026.
//

import UIKit

class OrderAlertViewController: UIViewController {

    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var ItemPrice: UILabel!
    @IBOutlet weak var itemCounter: UILabel!
    @IBOutlet weak var noteTextField: InspectableTextField!
    @IBOutlet weak var alertView: InspectableView!
    var foodItem: FoodItem?
    private var quantity: Int = 1
      private var unitPrice: Double = 0   // price of ONE item// ✅ DATA ONLY
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateData()
        animateIn()
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

    @IBAction func closeButtonTapped(_ sender: Any) {
        animateOut {
            self.dismiss(animated: false)
        }
    }
    
    @IBAction func increaseButtonTapped(_ sender: Any) {
        quantity += 1
        updateTotal()
    }

    @IBAction func decreaseButtonTapped(_ sender: Any) {
        guard quantity > 1 else { return }
        quantity -= 1
        updateTotal()
    }

    
    @IBAction func addToOrderButton(_ sender: Any) {
//        guard let item = foodItem else { return }
//
//        let order = Order(
//            id: UUID(),
//            quantity: quantity, name: item.name,
//            price: unitPrice,
//            note: noteTextField.text
//        )
//
//        // send order to cart / delegate / notification
//        animateOut {
//            self.dismiss(animated: false)
//        }
    }

    private func populateData() {
        guard let item = foodItem else { return }

        itemName.text = item.name
        unitPrice = Double(item.price) ?? 0.0       // ✅ take real price
        quantity = 1

        updateTotal()
    }
    private func updateTotal() {
        let total = Double(quantity) * unitPrice
        itemCounter.text = "\(quantity)"
       // ItemPrice.text = "\(total) EGP"
    }

}
