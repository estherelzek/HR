//
//  InvoiceOfOrderTableViewCell.swift
//  HR
//
//  Created by Esther Elzek on 15/01/2026.
//

import UIKit

class InvoiceOfOrderTableViewCell: UITableViewCell {

    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var itemName: UILabel!

    var onIncrease: (() -> Void)?
    var onDecrease: (() -> Void)?

    func configure(with order: Order) {
        quantityLabel.text = "\(order.quantity)"
        itemName.text = order.name
        itemPrice.text = "\(Double(order.quantity) * order.price) EGP"
    }

    @IBAction func decreaseQuantity(_ sender: Any) {
        onDecrease?()
    }

    @IBAction func increaseQuantity(_ sender: Any) {
        onIncrease?()
    }
}
