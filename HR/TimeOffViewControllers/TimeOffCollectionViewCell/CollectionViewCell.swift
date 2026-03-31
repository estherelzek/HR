//
//  CollectionViewCell.swift
//  HR
//
//  Created by Esther Elzek on 27/08/2025.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameOfLeaveType: UILabel!
    @IBOutlet weak var remainingBlalance: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var descriptLabel: UILabel!
    @IBOutlet weak var validUntilDate: UILabel!
   
    func configure(with leave: LeaveType) {
        print("Configuring cell with leave type: \(leave.name ?? "")")
            nameOfLeaveType.text = leave.name

            let remaining = leave.remainingBalance ?? 0
            let original = leave.originalBalance ?? 0
            remainingBlalance.text = "\(formatBalance(remaining)) / \(formatBalance(original))"

            descriptLabel.text = "\(leave.requestUnit?.uppercased() ?? "") AVAILABLE"
            validUntilDate.text = "Valid Untill 31/12/2025"
        }

        private func formatBalance(_ value: Double) -> String {
            // Show whole numbers without decimals (12.0 -> 12), else keep up to 2 decimals.
            if value.truncatingRemainder(dividingBy: 1) == 0 {
                return String(Int(value))
            }
            return String(format: "%.2f", value).replacingOccurrences(of: #"\.?0+$"#, with: "", options: .regularExpression)
        }
}
