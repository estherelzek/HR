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
        nameOfLeaveType.text = leave.name
        remainingBlalance.text = "\(Int(leave.remainingBalance ?? 0)) / \(Int(leave.originalBalance ?? 0))"
        descriptLabel.text = "\(leave.requestUnit?.uppercased() ?? "") AVAILABLE"
        validUntilDate.text = "Valid Untill 31/12/2025"
    }
}
