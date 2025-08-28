//
//  LogInViewController.swift
//  HR
//
//  Created by Esther Elzek on 07/08/2025.
//

import UIKit


class LogInViewController: UIViewController {
    
    @IBOutlet weak var signInTitleLabel: UILabel!
    @IBOutlet weak var companyIDlabel: UILabel!
    @IBOutlet weak var APIkeyLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwardTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    private let viewModel = LoginViewModel()   // ✅ Add ViewModel
    
    override func viewDidLoad() {
     //   loader.isHidden = true
        super.viewDidLoad()
        setUpTexts()
        setUpTextFields()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageChanged),
            name: NSNotification.Name("LanguageChanged"),
            object: nil
        )
        viewModel.onLoginSuccess = { [weak self] in
                   guard let self = self else { return }
                   let protectionMethodVC = ProtectionMethodViewController(nibName: "ProtectionMethodViewController", bundle: nil)
                   protectionMethodVC.modalPresentationStyle = .fullScreen
                   self.present(protectionMethodVC, animated: true)
        }
        viewModel.onLoginFailure = { [weak self] message in
        self?.showAlert(title: NSLocalizedString("login_failed", comment: ""), message: message)
        }
    }
    
    @IBAction func SignInButton(_ sender: Any) {
        loader.isHidden = false
        loader.startAnimating()
           guard let email = emailTextField.text, !email.isEmpty,
                 let password = passwardTextField.text, !password.isEmpty else {
               self.showAlert(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("please_enter_email_and_password", comment: ""))
               return
           }
           viewModel.login(apiKey: nil, companyId: nil, email: email, password: password)
        loader.stopAnimating()
        loader.isHidden = true
       }

    @objc private func languageChanged() {
        setUpTexts()
    }
}

extension LogInViewController {
    func setUpTexts() {
        signInTitleLabel.text = NSLocalizedString("sign_in_title", comment: "")
        companyIDlabel.text = NSLocalizedString("company_id", comment: "")
        APIkeyLabel.text = NSLocalizedString("api_key", comment: "")
        signInButton.setTitle(NSLocalizedString("sign_in_title", comment: ""), for: .normal)
        companyIDlabel.text = viewModel.companyId
        APIkeyLabel.text = viewModel.apiKey
    }

    func setUpTextFields() {
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("enter_email", comment: ""),
            attributes: [.foregroundColor: UIColor.lightGray]
        )
        passwardTextField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("enter_password", comment: ""),
            attributes: [.foregroundColor: UIColor.lightGray]
        )
    }
}
