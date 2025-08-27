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
    
    
    
 
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
        
}
