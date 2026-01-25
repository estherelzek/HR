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

    func configure(with item: LunchProduct) {
        print("Configure called for item: \(item.name)") // Step 1: entry check

        itemName.text = item.name
        descreptionLabel.text = item.description
        numberLabel.text = "\(item.price) EGP"

        updateFavIcon(isFavorite: item.isFavorite)
        print("Updated favorite icon: \(item.isFavorite)") // Step 2

        // Load Base64 image
        if let base64 = item.image_base64 {
            print("Base64 string exists, length: \(base64.count)") // Step 3
            if let image = UIImage.fromBase64(base64) {
                print("Successfully decoded Base64 to UIImage") // Step 4
                imageView.image = image
            } else {
                print("Failed to decode Base64 to UIImage") // Step 5
                imageView.image = UIImage(named: "burger")
            }
        } else {
            print("No Base64 string found, using placeholder") // Step 6
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
