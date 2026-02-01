//
//  ScanAndInfoViewController.swift
//  HR
//
//  Created by Esther Elzek on 01/09/2025.
//

import UIKit
import AVFoundation

class ScanAndInfoViewController: UIViewController , AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var companyInformationTextField: UITextField!
    @IBOutlet weak var scanQRbutton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var enterCompanyInfoLabel: UILabel!
    @IBOutlet weak var orButton: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        setUpTexts()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
         @objc private func companyFileImported() {
             if let text = UserDefaults.standard.string(forKey: "encryptedText") {
                 companyInformationTextField.text = text
                 print("🔐 Updated text field with imported encrypted text.")
             }
         }

         override func viewWillAppear(_ animated: Bool) {
             super.viewWillAppear(animated)
             companyInformationTextField.text = UserDefaults.standard.string(forKey: "encryptedText")
         }

         override func viewDidAppear(_ animated: Bool) {
             super.viewDidAppear(animated)
             companyInformationTextField.text = UserDefaults.standard.string(forKey: "encryptedText")
         }
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame =
                notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }

        let keyboardHeight = keyboardFrame.height

        scrollView.contentInset.bottom = keyboardHeight + 20
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight + 20
    }
    @objc func keyboardWillHide(notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

      
    @IBAction func scanButtonTapped(_ sender: Any) {
        // Hide all original UI elements
        hideOriginalUI()
        
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("No camera available")
            showOriginalUI() // Show UI back if camera fails
            return
        }

        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Error accessing camera: \(error)")
            showOriginalUI() // Show UI back if camera fails
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            print("Could not add camera input to session")
            showOriginalUI() // Show UI back if camera fails
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            print("Could not add metadata output")
            showOriginalUI() // Show UI back if camera fails
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // ✅ Add Cancel Button
        addCancelButton()
        
        captureSession.startRunning()
    }
    
    private func addCancelButton() {
        let cancelButton = UIButton(type: .system)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        cancelButton.layer.cornerRadius = 25
        cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        cancelButton.addTarget(self, action: #selector(cancelScanning), for: .touchUpInside)
        
        view.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cancelButton.widthAnchor.constraint(equalToConstant: 100),
            cancelButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    // ✅ Add these helper methods
    private func hideOriginalUI() {
        // Hide all your original UI elements
        scrollView.isHidden = true
        contentView.isHidden = true
        companyInformationTextField.isHidden = true
        scanQRbutton.isHidden = true
        doneButton.isHidden = true
        enterCompanyInfoLabel.isHidden = true
        orButton.isHidden = true
        
        // Also hide the view if you want to completely remove it
        // scrollView.removeFromSuperview() // Alternative if hiding doesn't work
    }

    private func showOriginalUI() {
        // Show all your original UI elements
        scrollView.isHidden = false
        contentView.isHidden = false
        companyInformationTextField.isHidden = false
        scanQRbutton.isHidden = false
        doneButton.isHidden = false
        enterCompanyInfoLabel.isHidden = false
        orButton.isHidden = false
    }

    // ✅ Updated Cancel scanning action
    @objc private func cancelScanning() {
        if captureSession != nil && captureSession.isRunning {
            captureSession.stopRunning()
        }
        
        previewLayer?.removeFromSuperlayer()
        
        // Remove any buttons we added
        view.subviews.forEach { subview in
            if let button = subview as? UIButton, button.title(for: .normal) == "Cancel" {
                button.removeFromSuperview()
            }
        }
        
        // ✅ Show original UI again
        showOriginalUI()
    }

  
   
    @IBAction func doneButtonTapped(_ sender: Any) {

        if let text = companyInformationTextField.text, !text.isEmpty {
            handleSuccessfulScan(text)
        } else {
            showInvalidQRAlert()
        }

    }
    private func handleSuccessfulScan(_ encryptedText: String) {
        do {
            let middleware = try Middleware.initialize(encryptedText)

            let defaults = UserDefaults.standard
            defaults.set(encryptedText, forKey: "encryptedText")
            defaults.set(middleware.companyId, forKey: "companyIdKey")
            defaults.set(middleware.apiKey, forKey: "apiKeyKey")
            defaults.set(middleware.baseUrl, forKey: "baseURL")

            // 🔥 Update API base URL
            API.updateDefaultBaseURL(middleware.baseUrl)

            print("✅ QR VALID — Going to Login")

            DispatchQueue.main.async {
                self.goToLogInViewController()
            }

        } catch {
            print("❌ Invalid QR Code")

            DispatchQueue.main.async {
                self.showInvalidQRAlert()
                self.cancelScanning()
            }
        }
    }


    @objc private func languageChanged() {
        setUpTexts()
    }

    func setUpTexts() {
        doneButton.setTitle(NSLocalizedString("done_button", comment: ""), for: .normal)
        enterCompanyInfoLabel.text = NSLocalizedString("enter-company-info", comment: "")
        orButton.text = NSLocalizedString("or", comment: "")
    }
    
    func applyBorderColors() {
        let fields = [companyInformationTextField]
        fields.forEach {
            $0?.layer.cornerRadius = 8
            $0?.layer.borderWidth = 1
            $0?.layer.borderColor = UIColor(named: "borderColor")?.resolvedColor(with: traitCollection).cgColor
        }
    }
}

extension ScanAndInfoViewController {
    // ✅ Also update the metadataOutput to show UI when QR is scanned
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {

        captureSession.stopRunning()

        guard
            let metadataObject = metadataObjects.first,
            let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
            let stringValue = readableObject.stringValue
        else {
            cancelScanning()
            return
        }

        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        print("📦 Scanned QR: \(stringValue)")

        // Clean scanner UI
        previewLayer?.removeFromSuperlayer()
        removeCancelButton()

        // 🚀 HANDLE SUCCESS → LOGIN
        handleSuccessfulScan(stringValue)
    }
    private func removeCancelButton() {
        view.subviews.forEach {
            if let button = $0 as? UIButton, button.title(for: .normal) == "Cancel" {
                button.removeFromSuperview()
            }
        }
    }

    private func showInvalidQRAlert() {
        let alert = UIAlertController(
            title: "Invalid QR Code",
            message: "This QR code is not a valid company access key.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            applyBorderColors()
        }
    }
}
extension ScanAndInfoViewController {
    func setupLayout() {

        [scrollView, contentView,
         scanQRbutton,
         orButton,
         enterCompanyInfoLabel,
         companyInformationTextField,
         doneButton].forEach {
            $0?.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([

            // 🔹 ScrollView fills screen
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // 🔹 ContentView inside ScrollView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            // ⭐ REQUIRED
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // ───────── SCAN QR BUTTON (BIG SQUARE) ─────────
            scanQRbutton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            scanQRbutton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            scanQRbutton.widthAnchor.constraint(equalToConstant: 220),
            scanQRbutton.heightAnchor.constraint(equalTo: scanQRbutton.widthAnchor),

            // ───────── OR LABEL ─────────
            orButton.topAnchor.constraint(equalTo: scanQRbutton.bottomAnchor, constant: 30),
            orButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            // ───────── ENTER COMPANY INFO LABEL ─────────
            enterCompanyInfoLabel.topAnchor.constraint(equalTo: orButton.bottomAnchor, constant: 12),
            enterCompanyInfoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            enterCompanyInfoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            // ───────── TEXT FIELD ─────────
            companyInformationTextField.topAnchor.constraint(equalTo: enterCompanyInfoLabel.bottomAnchor, constant: 8),
            companyInformationTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            companyInformationTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            companyInformationTextField.heightAnchor.constraint(equalToConstant: 44),

            // ───────── DONE BUTTON ─────────
            doneButton.topAnchor.constraint(equalTo: companyInformationTextField.bottomAnchor, constant: 30),
            doneButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            doneButton.heightAnchor.constraint(equalToConstant: 48),

            // 🔥 THIS ENABLES SCROLLING
            doneButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }


}
