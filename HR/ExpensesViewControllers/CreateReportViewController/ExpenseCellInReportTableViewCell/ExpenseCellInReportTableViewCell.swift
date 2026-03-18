//
//  ExpenseCellInReportTableViewCell.swift
//  HR
//
//  Created by Esther Elzek on 12/03/2026.
//

import UIKit

class ExpenseCellInReportTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var DateLabel: UILabel?
    @IBOutlet weak var totalLabel: UILabel?
    @IBOutlet weak var StatusLabel: UILabel?
    @IBOutlet weak var selectButton: UIButton?   // connect this in XIB

    // Notify controller when button is tapped
    var onToggleSelection: (() -> Void)?

    // Cell selection state for button UI
    var isExpenseSelected: Bool = false {
        didSet { updateSelectionUI() }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        separatorInset = .zero
        backgroundColor = .clear
        updateSelectionUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(with expense: EmployeeExpense, isSelected: Bool) {
        descriptionLabel?.text = expense.description.isEmpty ? expense.name : expense.description
        DateLabel?.text = expense.date
        totalLabel?.text = "\(expense.total_amount) \(expense.currency)"
        StatusLabel?.text = expense.state.capitalized

        switch expense.state {
        case "draft":
            StatusLabel?.textColor = .systemGray
        case "submitted":
            StatusLabel?.textColor = .systemYellow
        case "approved":
            StatusLabel?.textColor = UIColor.border
        default:
            StatusLabel?.textColor = .label
        }

        isExpenseSelected = isSelected
    }

    private func updateSelectionUI() {
        let imageName = isExpenseSelected ? "checkmark.circle.fill" : "circle"
        let image = UIImage(systemName: imageName)
        selectButton?.setImage(image, for: .normal)
        selectButton?.tintColor = isExpenseSelected ? .systemGreen : .systemGray3
    }

    @IBAction func selectButtonTapped(_ sender: Any) {
        isExpenseSelected.toggle()
        onToggleSelection?()
    }
}
