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
        descriptionLabel?.text = expense.name
        DateLabel?.text = expense.date
        totalLabel?.text = "\(expense.total_amount) \(expense.currency)"

        let isDeletable = expense.state.lowercased() == "draft" || expense.state.lowercased() == "submitted"

        // Show state with deletable hint
        let stateText = expense.state.capitalized
        let deletableHint = isDeletable
            ? ""
            : "  ⚠️ \(NSLocalizedString("expense.cannotDelete", comment: ""))"
        StatusLabel?.text = stateText

        switch expense.state.lowercased() {
        case "draft":
            StatusLabel?.textColor = .systemGray
        case "submitted":
            StatusLabel?.textColor = .systemYellow
        case "approved":
            StatusLabel?.textColor = UIColor.border
        default:
            StatusLabel?.textColor = .systemRed
        }

        // Dim cell if not deletable
//        contentView.alpha = isDeletable ? 1.0 : 0.5
//        selectButton?.isEnabled = isDeletable

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
