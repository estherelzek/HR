//
//  ProtectionMethodViewController.swift
//  HR
//
//  Created by Esther Elzek on 07/08/2025.
//

import UIKit

class ProtectionMethodViewController: UIViewController {
    
    @IBOutlet weak var fingurePrintTextField: UITextField!
    @IBOutlet weak var pinCodetextField: UITextField!
    @IBOutlet weak var donotShowAgain: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTextFields()
    }

    @IBAction func noProductionButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func dontShowThisAgain(_ sender: Any) {
        
    }
}

extension ProtectionMethodViewController {
    func setUpTextFields() {
        fingurePrintTextField.attributedPlaceholder = NSAttributedString(
           string: "Use Fingerprint",
           attributes: [.foregroundColor: UIColor.lightGray]
        )
        pinCodetextField.attributedPlaceholder = NSAttributedString(
           string: "Use Pin Code",
           attributes: [.foregroundColor: UIColor.lightGray]
       )
        donotShowAgain.layer.cornerRadius = 8
        donotShowAgain.layer.borderWidth = 1
        donotShowAgain.layer.borderColor = UIColor.fromHex("90476F").cgColor
        donotShowAgain.backgroundColor = .white
        
        fingurePrintTextField.layer.cornerRadius = 8
        fingurePrintTextField.layer.borderWidth = 1
        fingurePrintTextField.layer.borderColor = UIColor.fromHex("90476F").cgColor
        
        pinCodetextField.layer.cornerRadius = 8
        pinCodetextField.layer.borderWidth = 1
        pinCodetextField.layer.borderColor = UIColor.fromHex("90476F").cgColor
    }
}
