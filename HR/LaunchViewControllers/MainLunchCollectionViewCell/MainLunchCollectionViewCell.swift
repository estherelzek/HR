//
//  MainLunchCollectionViewCell.swift
//  HR
//
//  Created by Esther Elzek on 13/01/2026.
//

import UIKit

struct FoodItem {
    let name: String
    let description: String
    let price: String
    let imageName: String
    var isFavorite: Bool
}

class MainLunchCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var descreptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var favButton: UIButton!

    var onFavTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
    }

    func configure(with item: FoodItem) {
        itemName.text = item.name
        descreptionLabel.text = item.description
        numberLabel.text = "\(item.price) EGP"
        imageView.image = UIImage(named: item.imageName)

        updateFavIcon(isFavorite: item.isFavorite)
    }

    private func updateFavIcon(isFavorite: Bool) {
        let imageName = isFavorite ? "star" : "star.fill"
        favButton.setImage(UIImage(systemName: imageName), for: .normal)
        
    }

    @IBAction func favButtonTapped(_ sender: UIButton) {
        onFavTapped?()
    }
}
