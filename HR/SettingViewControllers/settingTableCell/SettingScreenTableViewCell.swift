//
//  SettingScreenTableViewCell.swift
//  HR
//
//  Created by Esther Elzek on 18/08/2025.
//

import UIKit
protocol SettingScreenTableViewCellDelegate: AnyObject {
    func didTapDropdown(in cell: SettingScreenTableViewCell)
}

class SettingScreenTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var dropdownButton: UIButton!
    
    weak var delegate: SettingScreenTableViewCellDelegate?

    func configure(with item: SettingItem, trait: UITraitCollection) {
        titleLabel.text = NSLocalizedString(item.titleKey, comment: "")
        if let iconName = item.iconName {
            logoImage.image = UIImage(systemName: iconName) ?? UIImage(named: iconName)
        } else {
            logoImage.image = nil
        }
        
        dropdownButton.isHidden = !item.isDropdownVisible
    }

    @IBAction func dropDownButtonTapped(_ sender: Any) {
        delegate?.didTapDropdown(in: self)
    }
}
