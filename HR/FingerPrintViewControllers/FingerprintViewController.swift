//
//  FingerprintViewController.swift
//  HR
//
//  Created by Esther Elzek on 07/08/2025.
//

import UIKit
import LocalAuthentication

import UIKit

class FingerprintViewController: UIViewController {
    
    let authManager = FingerPrintHandlingManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func fingerTouch(_ sender: Any) {
        authManager.authenticate { [weak self] success, message in
            guard let self = self else { return }
            if success {
                self.showAlert(title: "Success", message: "Fingerprint recognized.")
            } else {
                self.showAlert(title: "Error", message: message ?? "Authentication failed.")
            }
        }
    }
    
}
