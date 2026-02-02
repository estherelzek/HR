//
//  FaceAuthenticationViewController.swift
//  HR
//
//  Created by Esther Elzek on 12/10/2025.
//

import UIKit
import LocalAuthentication

class FaceAuthenticationViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!

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

        // 🔐 Start Face ID automatically when screen appears
        authenticateWithFaceID()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Face ID Authentication
    private func authenticateWithFaceID() {
        let context = LAContext()
        var error: NSError?

        print("🔍 Checking Face ID availability...")

        // Check if biometrics are available & enrolled
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            print("❌ Face ID not available: \(error?.localizedDescription ?? "Unknown error")")
            showUnavailableAlert(message: error?.localizedDescription ?? "Face ID is not available on this device.")
            return
        }

        // Ensure it is actually Face ID (not Touch ID)
        if context.biometryType != .faceID {
            print("⚠️ Biometry available, but NOT Face ID")
            showUnavailableAlert(message: "Face ID is not supported on this device.")
            return
        }

        print("✅ Face ID is available and enrolled")

        let reason = NSLocalizedString(
            "face_id_reason",
            comment: "Authenticate with Face ID to continue"
        )

        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: reason
        ) { success, authError in

            DispatchQueue.main.async {
                if success {
                    // ✅ SUCCESS
                    print("🎉 Face ID authentication SUCCESS")
                    self.handleSuccess()
                } else {
                    // ❌ FAILURE
                    let message = authError?.localizedDescription ?? "Authentication failed"
                    print("❌ Face ID authentication FAILED: \(message)")
                    self.handleFailure(error: authError)
                }
            }
        }
    }

    // MARK: - Success
    private func handleSuccess() {
        print("➡️ Proceeding to next screen")
        goToCheckingVC()
        // OR: dismiss(animated: true)
    }

    // MARK: - Failure Handling
    private func handleFailure(error: Error?) {
        let nsError = error as NSError?

        switch nsError?.code {
        case LAError.userCancel.rawValue:
            print("👤 User canceled Face ID")
            showRetryAlert(message: "Authentication was canceled.")

        case LAError.userFallback.rawValue:
            print("🔢 User chose fallback (PIN/password)")
            showFallbackAlert()

        case LAError.biometryLockout.rawValue:
            print("🔒 Face ID locked out (too many attempts)")
            showUnavailableAlert(message: "Face ID is locked. Unlock your phone and try again.")

        default:
            print("⚠️ Unknown Face ID error")
            showRetryAlert(message: "Face ID failed. Please try again.")
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
                self.authenticateWithFaceID()
            }
        ))

        alert.addAction(UIAlertAction(
            title: NSLocalizedString("cancel", comment: ""),
            style: .cancel,
            handler: { _ in
                print("🚪 User canceled authentication")
                self.dismiss(animated: true)
            }
        ))

        present(alert, animated: true)
    }

    private func showFallbackAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("use_pin", comment: ""),
            message: NSLocalizedString("fallback_pin_message", comment: "Use PIN instead"),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(
            title: NSLocalizedString("ok", comment: ""),
            style: .default,
            handler: { _ in
                print("➡️ Navigating to PIN screen")
                self.dismiss(animated: true)
            }
        ))

        present(alert, animated: true)
    }

    private func showUnavailableAlert(message: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("face_id_unavailable", comment: ""),
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(
            title: NSLocalizedString("ok", comment: ""),
            style: .default,
            handler: { _ in
                print("⬅️ Closing Face ID screen")
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
        titleLabel.text = NSLocalizedString("use_face_id", comment: "Use Face ID to continue")
    }
}
