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
        
        fingurePrintTextField.isUserInteractionEnabled = true
        fingurePrintTextField.delegate = self
        fingurePrintTextField.tintColor = .clear
        
        pinCodetextField.isUserInteractionEnabled = true
        pinCodetextField.delegate = self
        pinCodetextField.tintColor = .clear
    }


    @IBAction func noProductionButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func dontShowThisAgain(_ sender: Any) {
        
    }
    
    func navigateToFingerprintVC() {
        let fingerprintVC = FingerprintViewController(nibName: "FingerprintViewController", bundle: nil)
        fingerprintVC.modalPresentationStyle = .fullScreen
        present(fingerprintVC, animated: true, completion: nil)

    }
    func navigateToPinCodeVC() {
        let pinCodeVC = PinCodeViewController(nibName: "PinCodeViewController", bundle: nil)
        pinCodeVC.modalPresentationStyle = .fullScreen
        present(pinCodeVC, animated: true, completion: nil)

    }
}

extension ProtectionMethodViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == fingurePrintTextField {
            navigateToFingerprintVC()
            return false
        }
        if textField == pinCodetextField {
                navigateToPinCodeVC()
                return false
            }
        return true
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
    }
}
