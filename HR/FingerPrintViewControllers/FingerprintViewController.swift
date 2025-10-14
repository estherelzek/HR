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
    private let context = LAContext()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTexts()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageChanged),
            name: NSNotification.Name("LanguageChanged"),
            object: nil
        )
        authenticateWithBiometrics()
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    private func authenticateWithBiometrics() {
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            showAlert(title: "Error", message: "Biometrics not available")
            return
        }

        let reason = "Authenticate using Touch ID or Face ID"

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
            DispatchQueue.main.async {
                if success {
                    self.showAlert(title: "Success", message: "Fingerprint recognized")
                    self.goToChecking()
                } else {
                    self.showAlert(title: "Error", message: "Authentication failed")
                }
            }
        }
    }

    @objc private func languageChanged() { setUpTexts() }

    private func setUpTexts() {
        fingerPrintTitleLabel.text = "Use your fingerprint to continue"
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

}
