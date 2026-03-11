//
//  CategoriesPopUpTableViewCell.swift
//  HR
//
//  Created by Esther Elzek on 04/03/2026.
//

import UIKit

class CategoriesPopUpTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    
    private var onSelectionChanged: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLocalization()
        setupButton()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Do nothing - only handle button taps
    }
    
    private func setupLocalization() {
        // Empty titles - only show square icon
    }
    
    private func setupButton() {
        selectButton.contentHorizontalAlignment = .center
        selectButton.contentVerticalAlignment = .center
        selectButton.imageView?.contentMode = .scaleAspectFit
        selectButton.isUserInteractionEnabled = true
    }
    
    func configure(with supplier: LunchSupplier, isSelected: Bool, onSelectionChanged: @escaping () -> Void) {
        self.onSelectionChanged = onSelectionChanged
        
        // Set supplier data
        nameLabel.text = supplier.name
        numberLabel.text = supplier.phone ?? NSLocalizedString("categories.notAvailable", comment: "Not available")
        locationLabel.text = supplier.address ?? NSLocalizedString("categories.notAvailable", comment: "Not available")
        
        // Update UI based on selection state
        updateSelectionUI(isSelected: isSelected)
    }
    
    private func updateSelectionUI(isSelected: Bool) {
        if isSelected {
            let image = UIImage(systemName: "checkmark.square.fill")
            selectButton.setImage(image, for: .normal)
            selectButton.tintColor = .systemBlue
        } else {
            let image = UIImage(systemName: "square")
            selectButton.setImage(image, for: .normal)
            selectButton.tintColor = .lightGray
        }
    }
    
    @IBAction func selectButtonTapped(_ sender: Any) {
        onSelectionChanged?()
    }
}
