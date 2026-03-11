//
//  ExpensesTableViewCell.swift
//  HR
//
//  Created by Esther Elzek on 11/03/2026.
//

import UIKit

class ExpensesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var StatusLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        separatorInset = .zero
        backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(with expense: EmployeeExpense) {
        descriptionLabel.text = expense.description.isEmpty ? expense.name : expense.description
        DateLabel.text = expense.date
        totalLabel.text = "\(expense.total_amount) \(expense.currency)"
        StatusLabel.text = expense.state.capitalized

        switch expense.state {
        case "draft":
            StatusLabel.textColor = .systemGray
        case "reported":
            StatusLabel.textColor = .systemBlue
        case "submitted":
            StatusLabel.textColor = UIColor.border
        case "done":
            StatusLabel.textColor = .systemGray
        default:
            StatusLabel.textColor = .label
        }
    }
    
}
