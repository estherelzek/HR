//
//  resultTableViewCell.swift
//  HR
//
//  Created by Esther Elzek on 03/11/2025.
//

import UIKit

class resultTableViewCell: UITableViewCell {
    @IBOutlet weak var coloredButton: InspectableButton!
    @IBOutlet weak var numberOfAnnualLeaveLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
