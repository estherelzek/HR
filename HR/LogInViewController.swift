//
//  LogInViewController.swift
//  HR
//
//  Created by Esther Elzek on 07/08/2025.
//

import UIKit

class LogInViewController: UIViewController {
    
    @IBOutlet weak var companyIDlabel: UILabel!
    @IBOutlet weak var APIkeyLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwardTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTextFields()
    }
    
    @IBAction func SignInButton(_ sender: Any) {
        let protectionMethodVC = ProtectionMethodViewController(nibName: "ProtectionMethodViewController", bundle: nil)
        protectionMethodVC.modalPresentationStyle = .fullScreen
        present(protectionMethodVC, animated: true, completion: nil)
    }
    
}

extension LogInViewController {
    func setUpTextFields() {
        emailTextField.attributedPlaceholder = NSAttributedString(
           string: "Enter Email",
           attributes: [.foregroundColor: UIColor.lightGray]
        )
        passwardTextField.attributedPlaceholder = NSAttributedString(
           string: "Enter Password",
           attributes: [.foregroundColor: UIColor.lightGray]
       )
    }
}
