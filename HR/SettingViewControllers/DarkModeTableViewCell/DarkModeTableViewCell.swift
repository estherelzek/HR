//
//  DarkModeTableViewCell.swift
//  HR
//
//  Created by Esther Elzek on 02/09/2025.
//

import UIKit

protocol DarkModeTableViewCellDelegate: AnyObject {
    func darkModeSwitchChanged(isOn: Bool)
}

class DarkModeTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var modeSwitch: UISwitch!
    
    weak var delegate: DarkModeTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        modeSwitch.isOn = traitCollection.userInterfaceStyle == .dark
    }

    func configure(with item: SettingItem, trait: UITraitCollection) {
        
        titleLabel.text = NSLocalizedString(item.titleKey, comment: "")
        if let iconName = item.iconName {
            logoImage.image = UIImage(systemName: iconName) ?? UIImage(named: iconName)
        } else {
            logoImage.image = nil
        }
        
        if item.isDarkModeRow {
            if trait.userInterfaceStyle == .dark {
                modeSwitch.isOn = true
            } else {
                modeSwitch.isOn = false
            }
        }
    }

    @IBAction func switchButtonTapped(_ sender: UISwitch) {
        delegate?.darkModeSwitchChanged(isOn: sender.isOn)
    }
}
