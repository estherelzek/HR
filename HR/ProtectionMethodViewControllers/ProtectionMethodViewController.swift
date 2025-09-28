//
//  ProtectionMethodViewController.swift
//  HR
//
//  Created by Esther Elzek on 07/08/2025.
//

import UIKit
import LocalAuthentication

enum ProtectionMethod: String {
    case fingerprint
    case pin
    case none
}

class ProtectionMethodViewController: UIViewController {
    
    @IBOutlet weak var chooseProtectionMethod: UILabel!
    @IBOutlet weak var fingurePrintTextField: UITextField!
    @IBOutlet weak var pinCodetextField: UITextField!
    @IBOutlet weak var donotShowAgain: UIButton!
    @IBOutlet weak var donotShowThisLabel: UILabel!
    @IBOutlet weak var noProtectionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTexts()
        setUpTextFields()
        NotificationCenter.default.addObserver(self,selector: #selector(languageChanged),name: NSNotification.Name("LanguageChanged"),object: nil)
    }
   
    @IBAction func noProductionButtonTapped(_ sender: Any) {
        print("➡️ No Protection selected")
        UserDefaults.standard.set(ProtectionMethod.none.rawValue, forKey: "selectedProtectionMethod")
        goToChecking()
        }
        
        @IBAction func dontShowThisAgain(_ sender: Any) {
            UserDefaults.standard.dontShowProtectionScreen = true
            print("✅ Saved: Don't show this screen again")
            goToChecking()
        }

    func navigateToFingerprintVC() {
        UserDefaults.standard.set(ProtectionMethod.fingerprint.rawValue, forKey: "selectedProtectionMethod")
        let fingerprintVC = FingerprintViewController(nibName: "FingerprintViewController", bundle: nil)
        fingerprintVC.modalPresentationStyle = .fullScreen
        present(fingerprintVC, animated: true, completion: nil)
    }

    func navigateToPinCodeVC() {
        UserDefaults.standard.set(ProtectionMethod.pin.rawValue, forKey: "selectedProtectionMethod")
        let pinCodeVC = PinCodeViewController(nibName: "PinCodeViewController", bundle: nil)
        pinCodeVC.modalPresentationStyle = .fullScreen
        present(pinCodeVC, animated: true)
    }

    @objc private func languageChanged() {
        setUpTexts()
       }
    
    func applyBorderColors() {
        let fields = [pinCodetextField, fingurePrintTextField ,donotShowAgain]
        fields.forEach {
            $0?.layer.cornerRadius = 8
            $0?.layer.borderWidth = 1
            $0?.layer.borderColor = UIColor(named: "borderColor")?.resolvedColor(with: traitCollection).cgColor
        }
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            applyBorderColors()
        }
    }
}

extension ProtectionMethodViewController {
    func setUpTexts() {
        chooseProtectionMethod.text = NSLocalizedString("choose_protection_method", comment: "")
        donotShowThisLabel.text = NSLocalizedString("dont_show_this_again", comment: "")
        noProtectionButton.setTitle(NSLocalizedString("no_protection", comment: ""), for: .normal)
    }
    
    func setUpTextFields() {
        fingurePrintTextField.attributedPlaceholder = NSAttributedString(
           string: NSLocalizedString("use_fingerprint", comment: ""),
           attributes: [.foregroundColor: UIColor.lightGray]
        )
        pinCodetextField.attributedPlaceholder = NSAttributedString(
           string: NSLocalizedString("use_pin_code", comment: ""),
           attributes: [.foregroundColor: UIColor.lightGray]
       )
        fingurePrintTextField.isUserInteractionEnabled = true
        fingurePrintTextField.delegate = self
        fingurePrintTextField.tintColor = .clear
        pinCodetextField.isUserInteractionEnabled = true
        pinCodetextField.delegate = self
        pinCodetextField.tintColor = .clear
    }
}

