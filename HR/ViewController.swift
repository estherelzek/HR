//
//  ViewController.swift
//  HR
//
//  Created by Esther Elzek on 07/08/2025.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var companyInformationTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTextField()
    }
    
    @IBAction func scanButtonTapped(_ sender: Any) {
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        let loginVC = LogInViewController(nibName: "LogInViewController", bundle: nil)

        // Option 1: Present full screen (recommended for login)
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: true, completion: nil)

        // OR

        // Option 2: Replace root (if you want to discard current VC completely)
        /*
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = loginVC
            window.makeKeyAndVisible()
        }
        */
    }

}

extension ViewController {
    func setUpTextField() {
        companyInformationTextField.layer.cornerRadius = 8
        companyInformationTextField.layer.borderWidth = 1
        companyInformationTextField.layer.borderColor = UIColor.fromHex("90476F").cgColor
       }
}
