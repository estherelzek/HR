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
    case faceID
    case none
}

class ProtectionMethodViewController: UIViewController {
    
    @IBOutlet weak var chooseProtectionMethod: UILabel!
    @IBOutlet weak var fingurePrintTextField: UITextField!
    @IBOutlet weak var pinCodetextField: UITextField!
    @IBOutlet weak var donotShowAgain: UIButton!
    @IBOutlet weak var donotShowThisLabel: UILabel!
    @IBOutlet weak var noProtectionButton: UIButton!
    @IBOutlet weak var faceAuthentication: InspectableTextField!
    @IBOutlet weak var fingerIcone: UIImageView!
    @IBOutlet weak var faceIcone: UIImageView!
    @IBOutlet weak var pinicone: UIImageView!
    
    private var availableMethod: ProtectionMethod = .none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTexts()
        setUpTextFields()
        detectAvailableBiometric()
        NotificationCenter.default.addObserver(self,selector: #selector(languageChanged),name: NSNotification.Name("LanguageChanged"),object: nil)
    }
   
    @IBAction func noProductionButtonTapped(_ sender: Any) {
        UserDefaults.standard.set(ProtectionMethod.none.rawValue, forKey: "selectedProtectionMethod")
        goToChecking()
    }
        
    @IBAction func dontShowThisAgain(_ sender: Any) {
        UserDefaults.standard.dontShowProtectionScreen = true
        goToChecking()
    }

    func navigateToFingerprintVC() {
        UserDefaults.standard.set(ProtectionMethod.fingerprint.rawValue, forKey: "selectedProtectionMethod")
        let fingerprintVC = FingerprintViewController(nibName: "FingerprintViewController", bundle: nil)
        fingerprintVC.modalPresentationStyle = .fullScreen
        present(fingerprintVC, animated: true)
    }

    func navigateToPinCodeVC() {
        UserDefaults.standard.set(ProtectionMethod.pin.rawValue, forKey: "selectedProtectionMethod")
        let pinCodeVC = PinCodeViewController(nibName: "PinCodeViewController", bundle: nil)
        pinCodeVC.modalPresentationStyle = .fullScreen
        present(pinCodeVC, animated: true)
    }

    private func detectAvailableBiometric() {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            availableMethod = .none
            fingurePrintTextField.isHidden = true
            fingerIcone.isHidden = true
            
            faceAuthentication.isHidden = true
            faceIcone.isHidden = true
            return
        }

        switch context.biometryType {
        case .faceID:
            availableMethod = .faceID
            fingurePrintTextField.isHidden = true
            fingerIcone.isHidden = true
            faceAuthentication.isHidden = false
        case .touchID:
            availableMethod = .fingerprint
            fingurePrintTextField.isHidden = false
            faceIcone.isHidden = true
            faceAuthentication.isHidden = true
        default:
            availableMethod = .none
            fingurePrintTextField.isHidden = true
            faceIcone.isHidden = true
            fingerIcone.isHidden = true
            faceAuthentication.isHidden = true
        }
    }

    @objc private func languageChanged() {
        setUpTexts()
    }
    
    func applyBorderColors() {
        let fields = [pinCodetextField, fingurePrintTextField, donotShowAgain]
        fields.forEach {
            $0?.layer.cornerRadius = 8
            $0?.layer.borderWidth = 1
            $0?.layer.borderColor = UIColor(named: "borderColor")?.resolvedColor(with: traitCollection).cgColor
        }
    }
}

extension ProtectionMethodViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case fingurePrintTextField:
            navigateToFingerprintVC()
            return false
        case pinCodetextField:
            navigateToPinCodeVC()
            return false
        case faceAuthentication:
            UserDefaults.standard.set(ProtectionMethod.faceID.rawValue, forKey: "selectedProtectionMethod")
            let vc = FingerprintViewController(nibName: "FingerprintViewController", bundle: nil)
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
            return false
        default:
            return true
        }
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
        faceAuthentication.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("use_face_id", comment: ""),
            attributes: [.foregroundColor: UIColor.lightGray]
        )
        
        [fingurePrintTextField, pinCodetextField, faceAuthentication].forEach {
            $0?.delegate = self
            $0?.tintColor = .clear
            $0?.isUserInteractionEnabled = true
        }
    }
   
}
