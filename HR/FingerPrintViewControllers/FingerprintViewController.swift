//
//  FingerprintViewController.swift
//  HR
//
//  Created by Esther Elzek on 07/08/2025.
//

import UIKit
import LocalAuthentication

import UIKit
import LocalAuthentication

class FingerprintViewController: UIViewController {
    
    @IBOutlet weak var fingerPrintTitleLabel: UILabel!
    
    let authManager = FingerPrintHandlingManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTexts()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageChanged),
            name: NSNotification.Name("LanguageChanged"),
            object: nil
        )
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func fingerTouch(_ sender: Any) {
        authenticateWithBiometrics()
    }
    
    private func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?
        
        // Check if device supports biometrics
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = NSLocalizedString("authenticate_with_fingerprint", comment: "Authenticate with Fingerprint")
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.showAlert(
                            title: NSLocalizedString("success", comment: ""),
                            message: NSLocalizedString("fingerprint_recognized", comment: "")
                        )
                        self.goToChecking()
                    } else {
                        let message: String
                        if let laError = authenticationError as? LAError {
                            switch laError.code {
                            case .userCancel:
                                message = NSLocalizedString("user_canceled", comment: "User canceled authentication")
                            case .userFallback:
                                message = NSLocalizedString("use_passcode", comment: "User chose passcode")
                            case .biometryLockout:
                                message = NSLocalizedString("biometry_locked", comment: "Biometrics locked. Use passcode.")
                            default:
                                message = NSLocalizedString("authentication_failed", comment: "Authentication Failed")
                            }
                        } else {
                            message = NSLocalizedString("authentication_failed", comment: "Authentication Failed")
                        }
                        
                        self.showAlert(
                            title: NSLocalizedString("error", comment: ""),
                            message: message
                        )
                    }
                }
            }
        } else {
            // Biometrics not available (no Face ID/Touch ID)
            self.showAlert(
                title: NSLocalizedString("error", comment: ""),
                message: NSLocalizedString("biometrics_not_available", comment: "Biometrics not available")
            )
        }
    }
    
    @objc private func languageChanged() {
        setUpTexts()
    }
    
    private func setUpTexts() {
        fingerPrintTitleLabel.text = NSLocalizedString("fingerprint_title", comment: "")
    }
    
//    private func goToChecking() {
//        // Replace this with your real navigation logic
//        print("✅ Authentication success → Go to Checking screen")
//    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default))
        present(alert, animated: true)
    }
}
