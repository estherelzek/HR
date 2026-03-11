//
//  MainLunchCollectionViewCell.swift
//  HR
//
//  Created by Esther Elzek on 13/01/2026.
//


import UIKit
//import SDWebImage


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
        imageView.contentMode = .scaleAspectFill
    }

    func configure(with item: LunchProduct, isFavorite: Bool) {

        itemName.text = item.name
        descreptionLabel.text = item.description
        numberLabel.text = "\(item.price) EGP"

        updateFavIcon(isFavorite: isFavorite)

        if let base64 = item.image_base64,
           let image = UIImage.fromBase64(base64) {
            imageView.image = image
        } else {
            imageView.image = UIImage(named: "burger")
        }
    }

//    private func loadImage(for item: LunchProduct) {
//        // Prefer product image, fallback to category image
//        let imagePath = item.imageUrl ?? item.categoryImageUrl
//
//        guard let path = imagePath,
//              let url = ImageURLBuilder.build(path) else {
//            imageView.image = UIImage(named: "placeholder")
//            return
//        }
//
//        imageView.sd_setImage(
//            with: url,
//            placeholderImage: UIImage(named: "placeholder"),
//            options: [
//                .retryFailed,
//                .continueInBackground,
//                .scaleDownLargeImages
//            ]
//        )
//    }

    private func updateFavIcon(isFavorite: Bool) {
        let imageName = isFavorite ? "star.fill" : "star"
        favButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    @IBAction func favButtonTapped(_ sender: UIButton) {
        onFavTapped?()
    }
}
