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
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var noteTextField: InspectableTextField!
    @IBOutlet weak var alertView: InspectableView!
    
    var foodItem: LunchProduct?
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
        itemImage.layer.cornerRadius = 20
        itemImage.clipsToBounds = true
        itemImage.contentMode = .scaleAspectFill
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
        ItemPrice.text = "\(item.price) EGP"
        if let base64 = item.image_base64 {
            print("Base64 string exists, length: \(base64.count)") // Step 3
            if let image = UIImage.fromBase64(base64) {
                print("Successfully decoded Base64 to UIImage") // Step 4
                itemImage.image = image
            } else {
                print("Failed to decode Base64 to UIImage") // Step 5
                itemImage.image = UIImage(named: "burger")
            }
        } else {
            print("No Base64 string found, using placeholder") // Step 6
            itemImage.image = UIImage(named: "burger")
        }
        unitPrice = Double(item.price) ?? 0.0
        // ✅ take real price
        quantity = 1

        updateTotal()
    }
    private func updateTotal() {
        let total = Double(quantity) * unitPrice
        itemCounter.text = "\(quantity)"
       // ItemPrice.text = "\(total) EGP"
    }

}
