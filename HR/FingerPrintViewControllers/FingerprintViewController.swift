//
//  FingerprintViewController.swift
//  HR
//
//  Created by Esther Elzek on 07/08/2025.
//

import UIKit
import LocalAuthentication

class FingerprintViewController: UIViewController {
    
    @IBOutlet weak var fingerPrintTitleLabel: UILabel!
    
    let authManager = FingerPrintHandlingManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTexts()
        NotificationCenter.default.addObserver(self,selector: #selector(languageChanged),name: NSNotification.Name("LanguageChanged"),object: nil)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func fingerTouch(_ sender: Any) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = NSLocalizedString("authenticate_with_fingerprint", comment: "Authenticate with Fingerprint")

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.showAlert(
                            title: NSLocalizedString("success", comment: ""),
                            message: NSLocalizedString("fingerprint_recognized", comment: "")
                        )
                    } else {
                        self.showAlert(
                            title: NSLocalizedString("error", comment: ""),
                            message: NSLocalizedString("authentication_failed", comment: "Authentication Failed")
                        )
                    }
                }
            }
        } else {
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
}
