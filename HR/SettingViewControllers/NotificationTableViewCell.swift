//
//  NotificationTableViewCell.swift
//  HR
//
//  Created by Esther Elzek on 02/12/2025.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var TitLeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descreptionLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func configure(with item: NotificationItem) {
        TitLeLabel.text = item.title
        descreptionLable.text = item.description
        dateLabel.text = item.date
        
//        let imageName = item.isChecked ? "checkmark.circle.fill" : "circle"
//        checkButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
}
