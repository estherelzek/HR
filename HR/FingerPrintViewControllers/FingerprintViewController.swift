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

    // MARK: - Lifecycle
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // 🔐 Start Touch ID automatically
        authenticateWithTouchID()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Touch ID Authentication
    private func authenticateWithTouchID() {
        let context = LAContext()
        var error: NSError?

        print("🔍 Checking Touch ID availability...")

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            print("❌ Touch ID not available: \(error?.localizedDescription ?? "Unknown error")")
            showUnavailableAlert(message: error?.localizedDescription ?? "Touch ID is not available.")
            return
        }

        // Ensure it is Touch ID (not Face ID)
        if context.biometryType != .touchID {
            print("⚠️ Biometry available, but NOT Touch ID")
            showUnavailableAlert(message: "Touch ID is not supported on this device.")
            return
        }

        print("✅ Touch ID is available and enrolled")

        let reason = NSLocalizedString(
            "touch_id_reason",
            comment: "Authenticate using your fingerprint"
        )

        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: reason
        ) { success, authError in

            DispatchQueue.main.async {
                if success {
                    print("🎉 Touch ID authentication SUCCESS")
                    self.handleSuccess()
                } else {
                    let message = authError?.localizedDescription ?? "Authentication failed"
                    print("❌ Touch ID authentication FAILED: \(message)")
                    self.handleFailure(error: authError)
                }
            }
        }
    }

    // MARK: - Success
    private func handleSuccess() {
        print("➡️ Proceeding after Touch ID success")
        goToChecking()
        // OR dismiss(animated: true)
    }

    // MARK: - Failure Handling
    private func handleFailure(error: Error?) {
        let nsError = error as NSError?

        switch nsError?.code {
        case LAError.userCancel.rawValue:
            print("👤 User canceled Touch ID")
            showRetryAlert(message: "Authentication was canceled.")

        case LAError.userFallback.rawValue:
            print("🔢 User chose fallback (PIN)")
            showFallbackAlert()

        case LAError.biometryLockout.rawValue:
            print("🔒 Touch ID locked out")
            showUnavailableAlert(message: "Touch ID is locked. Unlock your phone and try again.")

        default:
            print("⚠️ Unknown Touch ID error")
            showRetryAlert(message: "Touch ID failed. Please try again.")
        }
    }

    // MARK: - Alerts

    private func showRetryAlert(message: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("authentication_failed", comment: ""),
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(
            title: NSLocalizedString("try_again", comment: ""),
            style: .default,
            handler: { _ in
                print("🔁 User tapped Try Again")
                self.authenticateWithTouchID()
            }
        ))

        alert.addAction(UIAlertAction(
            title: NSLocalizedString("cancel", comment: ""),
            style: .cancel,
            handler: { _ in
                print("🚪 User canceled Touch ID flow")
                self.dismiss(animated: true)
            }
        ))

        present(alert, animated: true)
    }

    private func showFallbackAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("use_pin", comment: ""),
            message: NSLocalizedString("fallback_pin_message", comment: ""),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(
            title: NSLocalizedString("ok", comment: ""),
            style: .default,
            handler: { _ in
                print("➡️ Navigating to PIN flow")
                self.dismiss(animated: true)
            }
        ))

        present(alert, animated: true)
    }

    private func showUnavailableAlert(message: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("touch_id_unavailable", comment: ""),
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(
            title: NSLocalizedString("ok", comment: ""),
            style: .default,
            handler: { _ in
                print("⬅️ Closing Touch ID screen")
                self.dismiss(animated: true)
            }
        ))

        present(alert, animated: true)
    }

    // MARK: - UI Actions
    @IBAction func backButtonTapped(_ sender: Any) {
        print("⬅️ Back button tapped")
        dismiss(animated: true)
    }

    // MARK: - Localization
    @objc private func languageChanged() {
        print("🌍 Language changed")
        setUpTexts()
    }

    private func setUpTexts() {
        fingerPrintTitleLabel.text = NSLocalizedString(
            "use_fingerprint",
            comment: "Use your fingerprint to continue"
        )
    }
}
