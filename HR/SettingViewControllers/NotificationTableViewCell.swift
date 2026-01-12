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
        dateLabel.text = formatDate(item.date)
    }

    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd" // only date

        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        } else {
            return dateString // fallback if parsing fails
        }
    }

}
