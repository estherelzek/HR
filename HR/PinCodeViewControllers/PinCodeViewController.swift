//
//  PinCodeViewController.swift
//  HR
//
//  Created by Esther Elzek on 10/08/2025.
//

import UIKit

class PinCodeViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstNum: UITextField!
    @IBOutlet weak var secoundNum: UITextField!
    @IBOutlet weak var thirdNum: UITextField!
    @IBOutlet weak var fouthNum: UITextField!
    @IBOutlet weak var forgetPasswardButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var hintLabel: UILabel!
    
    let pinKey = "savedPIN" // key for UserDefaults
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTexts()
        setUpTextFields()
        NotificationCenter.default.addObserver(self,selector: #selector(languageChanged),name: NSNotification.Name("LanguageChanged"),object: nil)
        if UserDefaults.standard.string(forKey: pinKey) == nil {
            UserDefaults.standard.set("1234", forKey: pinKey)
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        let enteredPin = "\(firstNum.text ?? "")\(secoundNum.text ?? "")\(thirdNum.text ?? "")\(fouthNum.text ?? "")"
        let savedPin = UserDefaults.standard.string(forKey: pinKey)
        if enteredPin == savedPin {
            navigateToTimeOffVC()
        } else {
            hintLabel.text = "❌ Wrong PIN, try again"
            hintLabel.textColor = .red
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func forgetpasswordButtonTapped(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: pinKey)
        hintLabel.text = "PIN reset. Please set a new one."
        hintLabel.textColor = .orange
    }
    
    func navigateToTimeOffVC() {
        let timeOffVC = TimeOffViewController(nibName: "TimeOffViewController", bundle: nil)
        timeOffVC.modalPresentationStyle = .fullScreen
        present(timeOffVC, animated: true, completion: nil)
    }
    
    @objc private func languageChanged() {
        setUpTexts()
    }
}


extension PinCodeViewController {
    func setUpTexts() {
        titleLabel.text = NSLocalizedString("pin_code_title", comment: "")
        hintLabel.text = NSLocalizedString("pin_code_hint", comment: "")
        forgetPasswardButton.setTitle(NSLocalizedString("forget_password", comment: ""), for: .normal)
        nextButton.setTitle(NSLocalizedString("next_button", comment: ""), for: .normal)
    }
    
    func setUpTextFields() {
        firstNum.placeholder = NSLocalizedString("digit_placeholder", comment: "")
        secoundNum.placeholder = NSLocalizedString("digit_placeholder", comment: "")
        thirdNum.placeholder = NSLocalizedString("digit_placeholder", comment: "")
        fouthNum.placeholder = NSLocalizedString("digit_placeholder", comment: "")
    }
}


