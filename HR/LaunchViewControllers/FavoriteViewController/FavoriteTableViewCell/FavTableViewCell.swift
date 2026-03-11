//
//  FavTableViewCell.swift
//  HR
//
//  Created by Esther Elzek on 25/02/2026.
//

import UIKit

class FavTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    
    @IBOutlet weak var addToCartButton: InspectableButton!
    var onRemoveTapped: (() -> Void)?
    var onAddToCartTapped: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        itemImage.layer.cornerRadius = 10
        itemImage.clipsToBounds = true
        itemImage.contentMode = .scaleAspectFill
        
        // ✅ Observe language changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateLocalizations),
            name: NSNotification.Name("LanguageChanged"),
            object: nil
        )
    }
    
    func configure(with item: LunchProduct) {
        itemName.text = item.name
        itemPrice.text = "\(item.price) EGP"
        
        if let base64 = item.image_base64,
           let image = UIImage.fromBase64(base64) {
            itemImage.image = image
        }
        
        updateLocalizations() // ✅ apply correct language on every configure call
    }
    
    // ✅ Single place that sets all localized text in this cell
    @objc private func updateLocalizations() {
        addToCartButton.setTitle(NSLocalizedString("add_to_cart_button", comment: ""), for: .normal)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func addToCartButtonTapped(_ sender: Any) {
        onAddToCartTapped?()
    }
    
    @IBAction func favStarButtonTapped(_ sender: Any) {
        onRemoveTapped?()
    }
}
