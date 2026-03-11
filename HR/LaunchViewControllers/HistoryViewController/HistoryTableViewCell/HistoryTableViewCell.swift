//
//  HistoryTableViewCell.swift
//  HR
//
//  Created by Esther Elzek on 26/02/2026.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var mulilineLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var reOrderButton: InspectableButton!
    var onReorderTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mulilineLabel.numberOfLines = 0
        selectionStyle = .none
        
        updateLocalizations()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateLocalizations),
            name: NSNotification.Name("LanguageChanged"),
            object: nil
        )
    }
    
    func configure(with order: HistoryOrder) {
        mulilineLabel.text = order.items.map {
            "\($0.quantity) x \($0.name)"
        }.joined(separator: "\n")
        
        let format = NSLocalizedString("history_total_price_format", comment: "")
        priceLabel.text = String(format: format, "\(order.total)")
        
        updateLocalizations()
    }
    
    @objc private func updateLocalizations() {
        reOrderButton.setTitle(NSLocalizedString("reorder_button", comment: ""), for: .normal)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func reOrderButtonTapped(_ sender: Any) {
        onReorderTapped?()
    }
}
