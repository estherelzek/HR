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
    @IBOutlet weak var selectButton: UIButton?
    
    var isExpenseSelected: Bool = false {
        didSet { updateSelectionUI() }
    }
    var onToggleSelection: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Hide select button by default — shown only in multi-select mode
    //    selectButton?.isHidden = true
        updateSelectionUI()
    }

    
    @IBAction func selectButtonTapped(_ sender: Any) {
        isExpenseSelected.toggle()
        onToggleSelection?()
    }
    private func updateSelectionUI() {
        let imageName = isExpenseSelected ? "checkmark.circle.fill" : "circle"
        let image = UIImage(systemName: imageName)
        selectButton?.setImage(image, for: .normal)
        selectButton?.tintColor = isExpenseSelected ? .systemGreen : .lightGray
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func configure(with report: ReportListItem) {
        print("Configuring cell with report: \(report)")
        // Bold title
        let titleAttr = NSAttributedString(
            string: report.sheet_name,
            attributes: [
                .font: UIFont.boldSystemFont(ofSize: 16),
                .foregroundColor: UIColor.white
            ]
        )
        descriptionLabel.attributedText = titleAttr

        // Amount with tax
        let taxFormat = NSLocalizedString("expense.cell.withTaxes", comment: "")
        let amountString = String(format: "%.2f", report.expense.amount)
        let taxText = String(format: taxFormat, amountString, "0")
        totalLabel.text = taxText
        totalLabel.font = UIFont.systemFont(ofSize: 14)
        totalLabel.textColor = .lightGray

        // Date and state
        let sentenceFormat = NSLocalizedString("expense.cell.addedOn", comment: "")
        let fullText = String(format: sentenceFormat, report.expense.date, report.state)
        let attributed = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.lightGray
            ]
        )

        if let dateRange = fullText.range(of: report.expense.date) {
            let nsRange = NSRange(dateRange, in: fullText)
            attributed.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 14), range: nsRange)
            attributed.addAttribute(.foregroundColor, value: UIColor.white, range: nsRange)
        }

        if let stateRange = fullText.range(of: report.state) {
            let nsRange = NSRange(stateRange, in: fullText)
            attributed.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 14), range: nsRange)

            let stateColor: UIColor
            switch report.state {
            case "submit":     stateColor = .systemYellow
            case "approve":   stateColor = UIColor.border
            default:           stateColor = .white
            }
            attributed.addAttribute(.foregroundColor, value: stateColor, range: nsRange)
        }

        DateLabel.attributedText = attributed
        DateLabel.numberOfLines = 0

        StatusLabel.isHidden = false
        StatusLabel.text = report.state.capitalized
        StatusLabel.font = UIFont.boldSystemFont(ofSize: 13)
        switch report.state {
        case "submit":     StatusLabel.textColor = .systemYellow
        case "approve":   StatusLabel.textColor = UIColor.border
        default:           StatusLabel.textColor = .white
        }
    }

    func configure(with expense: EmployeeExpense) {

        // Bold title
        let titleText = expense.name
        let titleAttr = NSAttributedString(
            string: titleText,
            attributes: [
                .font: UIFont.boldSystemFont(ofSize: 16),
                .foregroundColor: UIColor.white
            ]
        )
        descriptionLabel.attributedText = titleAttr

        // "6.0 LE with taxes 0"
        let taxFormat = NSLocalizedString("expense.cell.withTaxes", comment: "")
        let amountString = String(format: "%.2f", expense.total_amount)
        let taxAmountString = String(format: "%.2f", expense.tax_amount)
        let taxText = String(format: taxFormat, amountString, taxAmountString)
        totalLabel.text = taxText
        totalLabel.font = UIFont.systemFont(ofSize: 14)
        totalLabel.textColor = .lightGray

        let sentenceFormat = NSLocalizedString("expense.cell.addedOn", comment: "")
        let fullText = String(format: sentenceFormat, expense.date, expense.state)
        let attributed = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.lightGray
            ]
        )

        if let dateRange = fullText.range(of: expense.date) {
            let nsRange = NSRange(dateRange, in: fullText)
            attributed.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 14), range: nsRange)
            attributed.addAttribute(.foregroundColor, value: UIColor.border, range: nsRange)
        }

        if let stateRange = fullText.range(of: expense.state) {
            let nsRange = NSRange(stateRange, in: fullText)
            attributed.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 14), range: nsRange)

            let stateColor: UIColor
            switch expense.state {
            case "draft":      stateColor = .systemGray
            case "submitted":  stateColor = .systemYellow
            case "approved":   stateColor = UIColor.border
            default:           stateColor = .white
            }
            attributed.addAttribute(.foregroundColor, value: stateColor, range: nsRange)
        }

        DateLabel.attributedText = attributed
        DateLabel.numberOfLines = 0

        StatusLabel.isHidden = false
        StatusLabel.text = expense.state.capitalized
        StatusLabel.font = UIFont.boldSystemFont(ofSize: 13)
        switch expense.state {
        case "draft":      StatusLabel.textColor = .systemGray
        case "submitted":  StatusLabel.textColor = .systemYellow
        case "approved":   StatusLabel.textColor = UIColor.border
        default:           StatusLabel.textColor = .white
        }
        
    }
    
}
