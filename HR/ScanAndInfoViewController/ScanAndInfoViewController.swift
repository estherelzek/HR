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
        NotificationCenter.default.addObserver(self,selector: #selector(languageChanged),name: NSNotification.Name("LanguageChanged"),object: nil)
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
        let encryptedText =  companyInformationTextField.text ?? ""
        do {
            let middleware = try Middleware.initialize(encryptedText)
            UserDefaults.standard.set(middleware.companyId, forKey: "companyId")
            UserDefaults.standard.set(middleware.apiKey, forKey: "apiKey")
            UserDefaults.standard.set(middleware.baseUrl, forKey: "baseUrl")
            print("middleware : success : \(middleware.apiKey) : \(middleware.companyId): \(middleware.baseUrl)")
            goToLogInViewController()
        } catch {
            print("Failed to decrypt: \(error)")
        }
    }

    @objc private func languageChanged() {
        setUpTexts()
    }

    func setUpTexts() {
        doneButton.setTitle(NSLocalizedString("done_button", comment: ""), for: .normal)
        scanQRbutton.setTitle(NSLocalizedString("scan-QR", comment: ""), for: .normal)
        enterCompanyInfoLabel.text = NSLocalizedString("enter-company-info", comment: "")
        orButton.text = NSLocalizedString("or", comment: "")
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
            UserDefaults.standard.set(stringValue, forKey: "scannedQRCode")
            previewLayer.removeFromSuperlayer()
        }
    }
}
