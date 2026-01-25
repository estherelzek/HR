//
//  LogInViewController.swift
//  HR
//
//  Created by Esther Elzek on 07/08/2025.
//

import UIKit


class LogInViewController: UIViewController {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var signInTitleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwardTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet var uiview: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    private let viewModel = LoginViewModel()
    
    // ✅ Add property to track password visibility
    private var isPasswordVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setUpTexts()
        setUpLeasenerToViewModel()
       // setupEmailIcon()
        // ✅ Setup password toggle button
        setupPasswordToggleButton()
        
        NotificationCenter.default.addObserver(self,selector: #selector(languageChanged),name: NSNotification.Name("LanguageChanged"),object: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
          tapGesture.cancelsTouchesInView = false  // allows button taps to still work
          view.addGestureRecognizer(tapGesture)
    }
    
    // ✅ Setup password toggle button method
    private func setupPasswordToggleButton() {
        // Create eye button
        let eyeButton = UIButton(type: .custom)
        eyeButton.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        
        // Set initial eye icon (closed/secure)
        setEyeIcon(for: eyeButton, isVisible: false)
        
        // Add action
        eyeButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        // Create container view to hold the button
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        containerView.addSubview(eyeButton)
        
        // Position button in container
        eyeButton.center = containerView.center
        
        // Set right view for password text field
        passwardTextField.rightView = containerView
        passwardTextField.rightViewMode = .always
        
        // Ensure password is initially secure
        passwardTextField.isSecureTextEntry = true
    }
    private func setupEmailIcon() {
        // Left icon (envelope)
        let emailImageView = UIImageView(image: UIImage(systemName: "envelope"))
        emailImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 16)
        emailImageView.contentMode = .scaleAspectFit
        emailImageView.tintColor = UIColor.gray
        
        let leftContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        leftContainerView.addSubview(emailImageView)
        emailImageView.center = leftContainerView.center
        
        emailTextField.leftView = leftContainerView
        emailTextField.leftViewMode = .always
        
        // Optional: Add clear button on the right
        let clearButton = UIButton(type: .custom)
        clearButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        clearButton.tintColor = UIColor.lightGray
        clearButton.addTarget(self, action: #selector(clearEmailField), for: .touchUpInside)
        
        let rightContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        rightContainerView.addSubview(clearButton)
        clearButton.center = rightContainerView.center
        
        emailTextField.rightView = rightContainerView
        emailTextField.rightViewMode = .whileEditing
        emailTextField.clearButtonMode = .never // Disable default clear button
    }

    @objc private func clearEmailField() {
        emailTextField.text = ""
    }
    // ✅ Set appropriate eye icon
    private func setEyeIcon(for button: UIButton, isVisible: Bool) {
        let imageName = isVisible ? "eye.slash.fill" : "eye.fill"
        let image = UIImage(systemName: imageName)
        
        // Set image with proper color
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.gray
        
        // Add accessibility label
        button.accessibilityLabel = isVisible ? "Hide password" : "Show password"
    }
    
    // ✅ Toggle password visibility
    @objc private func togglePasswordVisibility() {
        isPasswordVisible.toggle()
        passwardTextField.isSecureTextEntry = !isPasswordVisible
        
        // Update eye icon
        if let containerView = passwardTextField.rightView,
           let eyeButton = containerView.subviews.first as? UIButton {
            setEyeIcon(for: eyeButton, isVisible: isPasswordVisible)
        }
        
        // Maintain cursor position when toggling
        if let textRange = passwardTextField.textRange(from: passwardTextField.beginningOfDocument,
                                                      to: passwardTextField.endOfDocument),
           let text = passwardTextField.text {
            passwardTextField.replace(textRange, withText: text)
        }
    }
    
    // Rest of your existing code remains the same...
    @IBAction func SignInButton(_ sender: Any) {
        loader.isHidden = false
        loader.startAnimating()
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwardTextField.text, !password.isEmpty else {
            self.showAlert(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("please_enter_email_and_password", comment: ""))
            return
        }
        viewModel.login(apiKey: nil, companyId: nil, email: email, password: password)
    }
    
    // MARK: - Keyboard Handling
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }

    @objc private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height + 20, right: 0)
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset

        if let activeField = view.currentFirstResponder() as? UITextField {
            let fieldFrame = activeField.convert(activeField.bounds, to: scrollView)
            scrollView.scrollRectToVisible(fieldFrame, animated: true)
        }
    }

    @objc private func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    @objc private func languageChanged() {
        setUpTexts()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func applyBorderColors() {
        let fields = [emailTextField, passwardTextField]
        fields.forEach {
            $0?.layer.cornerRadius = 8
            $0?.layer.borderWidth = 1
            $0?.layer.borderColor = UIColor(named: "borderColor")?.resolvedColor(with: traitCollection).cgColor
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            applyBorderColors()
        }
    }
}

extension LogInViewController {
    func setUpTexts() {
        signInTitleLabel.text = NSLocalizedString("sign_in_title", comment: "")
       
        signInButton.setTitle(NSLocalizedString("sign_in_title", comment: ""), for: .normal)
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("enter_email", comment: ""),
            attributes: [.foregroundColor: UIColor.lightGray]
        )
        passwardTextField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("enter_password", comment: ""),
            attributes: [.foregroundColor: UIColor.lightGray]
        )
        emailLabel.text = NSLocalizedString("email", comment: "")
        passwordLabel.text = NSLocalizedString("password", comment: "")
    }
    
    func setUpLeasenerToViewModel(){
        viewModel.onLoginSuccess = { [weak self] in
            guard let self = self else { return }
            let protectionMethodVC = ProtectionMethodViewController(nibName: "ProtectionMethodViewController", bundle: nil)
            protectionMethodVC.modalPresentationStyle = .fullScreen
            calculateClockDifference()
            self.present(protectionMethodVC, animated: true)
        }
        viewModel.onLoginFailure = { [weak self] message in
            self?.showAlert(title: NSLocalizedString("login_failed", comment: ""), message: NSLocalizedString(message, comment: ""))
            self?.loader.stopAnimating()
            self?.loader.isHidden = true
        }
    }
}

// MARK: - Helper to find current first responder
extension UIView {
    func currentFirstResponder() -> UIResponder? {
        if self.isFirstResponder { return self }
        for subview in subviews {
            if let responder = subview.currentFirstResponder() {
                return responder
            }
        }
        return nil
    }
}

extension LogInViewController {
    private func setupConstraints() {
        // Disable autoresizing masks
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        userImage.translatesAutoresizingMaskIntoConstraints = false
        signInTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        passwardTextField.translatesAutoresizingMaskIntoConstraints = false
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        loader.translatesAutoresizingMaskIntoConstraints = false
        
        // 1. ScrollView constraints (fills entire view)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 2. ContentView constraints inside ScrollView
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // 3. User Image constraints
        NSLayoutConstraint.activate([
            userImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            userImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            userImage.widthAnchor.constraint(equalToConstant: 120),
            userImage.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        // 4. Sign In Title constraints
        NSLayoutConstraint.activate([
            signInTitleLabel.topAnchor.constraint(equalTo: userImage.bottomAnchor, constant: 30),
            signInTitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        // 5. Email Label constraints
        NSLayoutConstraint.activate([
            emailLabel.topAnchor.constraint(equalTo: signInTitleLabel.bottomAnchor, constant: 40),
            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // 6. Email TextField constraints
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // 7. Password Label constraints
        NSLayoutConstraint.activate([
            passwordLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            passwordLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // 8. Password TextField constraints
        NSLayoutConstraint.activate([
            passwardTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 8),
            passwardTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            passwardTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            passwardTextField.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // 9. Sign In Button constraints
        NSLayoutConstraint.activate([
            signInButton.topAnchor.constraint(equalTo: passwardTextField.bottomAnchor, constant: 40),
            signInButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            signInButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            signInButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // 10. Loader constraints
        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: signInButton.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: signInButton.centerYAnchor)
        ])
        
        // 11. Bottom constraint for contentView (ensures scrolling)
        let bottomConstraint = contentView.bottomAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 40)
        bottomConstraint.priority = .defaultHigh
        bottomConstraint.isActive = true
    }
}
