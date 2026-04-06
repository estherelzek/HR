//
//  AnalyticDistributionCellTableViewCell.swift
//  HR
//
//  Created by Esther Elzek on 08/03/2026.
//

import UIKit

class AnalyticDistributionCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var percentageTextField: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    
    var onDeleteTapped: (() -> Void)?
    var onPercentageChanged: ((Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        selectionStyle = .none
        percentageTextField.delegate = self
        percentageTextField.keyboardType = .numberPad
        percentageTextField.borderStyle = .roundedRect
        percentageTextField.layer.borderWidth = 1
        percentageTextField.layer.cornerRadius = 6
        percentageTextField.layer.borderColor = UIColor.lightGray.cgColor
        percentageTextField.textAlignment = .center
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        deleteButton.tintColor = .systemRed
        accountNameLabel.font = .systemFont(ofSize: 16, weight: .medium)
    }
    
    func configure(
        accountName: String,
        percentage: Int,
        onDeleteTapped: @escaping () -> Void,
        onPercentageChanged: @escaping (Int) -> Void
    ) {
        accountNameLabel.text = accountName
        percentageTextField.text = String(percentage)
        self.onDeleteTapped = onDeleteTapped
        self.onPercentageChanged = onPercentageChanged
    }
    
    @objc private func deleteButtonTapped() {
        onDeleteTapped?()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension AnalyticDistributionCellTableViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ UITextField: UITextField) {
        if let text = UITextField.text, let percentage = Int(text), percentage > 0, percentage <= 100 {
            onPercentageChanged?(percentage)
        }
    }
}
