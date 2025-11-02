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
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTexts()
        companyInformationTextField.text = UserDefaults.standard.string(forKey: "encryptedText")
        NotificationCenter.default.addObserver(self,selector: #selector(languageChanged),name: NSNotification.Name("LanguageChanged"),object: nil)
        NotificationCenter.default.addObserver(self,
                 selector: #selector(companyFileImported),
                 name: NSNotification.Name("CompanyFileImported"),
                 object: nil)
         }
    
         // ✅ Update text field when .ihkey file is imported
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

      
    @IBAction func scanButtonTapped(_ sender: Any) {
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("No camera available")
            return
        }

        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Error accessing camera: \(error)")
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            print("Could not add camera input to session")
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            print("Could not add metadata output")
            return
        }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        captureSession.startRunning()
    }

    @IBAction func doneButtonTapped(_ sender: Any) {
//        let encryptedText =  companyInformationTextField.text ?? ""
//        do {
//            let middleware = try Middleware.initialize(encryptedText)
//            UserDefaults.standard.set(middleware.companyId, forKey: "companyIdKey")
//            UserDefaults.standard.set("HKP0Pt4zTDVf3ZHcGNmM4yx6", forKey: "apiKeyKey")
//            UserDefaults.standard.set(middleware.baseUrl, forKey: "baseUrl")
//            print("middleware : success : \(middleware.apiKey) : \(middleware.companyId): \(middleware.baseUrl)")
        
        if companyInformationTextField.text == nil {
            let alert = UIAlertController(title: "Error", message: "Please enter your company information", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else  {
            goToLogInViewController()
        }
            
//        } catch {
//            print("Failed to decrypt: \(error)")
//        }
    }

    @objc private func languageChanged() {
        setUpTexts()
    }

    func setUpTexts() {
        doneButton.setTitle(NSLocalizedString("done_button", comment: ""), for: .normal)
    //    scanQRbutton.setTitle(NSLocalizedString("scan-QR", comment: ""), for: .normal)
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
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            // 🧩 Save scanned text
            UserDefaults.standard.set(stringValue, forKey: "scannedQRCode")
            print("📦 Scanned QR Data: \(stringValue)")
            
            // 🧩 Show it in your text field immediately
            companyInformationTextField.text = stringValue
            
            // 🧩 Optional: also store it as "encryptedText" if that’s what you use elsewhere
            UserDefaults.standard.set(stringValue, forKey: "encryptedText")
            
            // Remove preview
            previewLayer.removeFromSuperlayer()
            
            // Optional: show confirmation alert
            let alert = UIAlertController(title: "QR Scanned",
                                          message: "Company info fetched successfully!",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            applyBorderColors()
        }
    }
}
