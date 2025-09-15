//
//  PinCodeViewController.swift
//  HR
//
//  Created by Esther Elzek on 10/08/2025.
//

import UIKit

enum PinMode {
    case set
    case confirm
    case enter
}

class PinCodeViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstNum: UITextField!
    @IBOutlet weak var secoundNum: UITextField!
    @IBOutlet weak var thirdNum: UITextField!
    @IBOutlet weak var fouthNum: UITextField!
    @IBOutlet weak var forgetPasswardButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var hintLabel: UILabel!
    
    let pinKey = "savedPIN"
    var mode: PinMode = .set
    private var tempPin: String? // for storing first PIN before confirm
    var needToChangeProtectionMethod: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Decide mode at startup
        if let _ = UserDefaults.standard.string(forKey: pinKey) {
            mode = .enter
        } else {
            mode = .set
        }
        
        setUpLabelsTexts()
        setUpTextFields()
        setUpplaceholderTextFields()
        configureUIForMode()
    }
    
    // MARK: - Next Button Action
    @IBAction func nextButtonTapped(_ sender: Any) {
        let enteredPin = "\(firstNum.text ?? "")\(secoundNum.text ?? "")\(thirdNum.text ?? "")\(fouthNum.text ?? "")"
        
        switch mode {
        case .set:
            if enteredPin.count == 4 {
                tempPin = enteredPin
                mode = .confirm
                clearTextFields()
                configureUIForMode()
            }
            
        case .confirm:
            if enteredPin == tempPin {
                UserDefaults.standard.set(enteredPin, forKey: pinKey)
                mode = .enter
                clearTextFields()
                configureUIForMode()
                hintLabel.text = "✅ PIN saved successfully! Now enter to continue."
                hintLabel.textColor = .green
            } else {
                hintLabel.text = "❌ PINs do not match. Try again."
                hintLabel.textColor = .red
                mode = .set
                clearTextFields()
                configureUIForMode()
            }
            
        case .enter:
            let savedPin = UserDefaults.standard.string(forKey: pinKey)
            if enteredPin == savedPin {
                print("🎉 PIN correct → Continue to app")
                if needToChangeProtectionMethod{
                    UserDefaults.standard.removeObject(forKey: pinKey)
                    mode = .set
                    clearTextFields()
                    configureUIForMode()
                    goToProtectionMethod()
                }else {
                    goToCheckingVC()
                }
               
            } else {
                hintLabel.text = "❌ Wrong PIN, try again."
                hintLabel.textColor = .red
                clearTextFields()
            }
        }
    }
    
    @IBAction func forgetpasswordButtonTapped(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: pinKey)
        mode = .set
        configureUIForMode()
        clearTextFields()
        hintLabel.text = "🔄 PIN reset. Please set a new one."
        hintLabel.textColor = .orange
    }
    
    // MARK: - Helpers
    private func configureUIForMode() {
        switch mode {
        case .set:
            titleLabel.text = "Set your new 4-digit PIN"
            nextButton.setTitle("Next", for: .normal)
        case .confirm:
            titleLabel.text = "Confirm your PIN"
            nextButton.setTitle("Confirm", for: .normal)
        case .enter:
            titleLabel.text = "Enter your PIN"
            nextButton.setTitle("Unlock", for: .normal)
        }
    }
    
    private func clearTextFields() {
        [firstNum, secoundNum, thirdNum, fouthNum].forEach { $0?.text = "" }
        firstNum.becomeFirstResponder()
    }
    
    private func goToCheckingVC() {
        if let rootVC = self.view.window?.rootViewController as? ViewController {
            let checkVC = CheckingViewController(nibName: "CheckingViewController", bundle: nil)
            rootVC.switchTo(viewController: checkVC)
            rootVC.bottomBarView.isHidden = false
            rootVC.homeButton.tintColor = .purplecolor
            rootVC.timeOffButton.tintColor = .lightGray
            rootVC.settingButton.tintColor = .lightGray
        }
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    private func goToProtectionMethod() {
        if let rootVC  = self.view.window?.rootViewController as? ViewController {
            let protectionMethodVC = ProtectionMethodViewController(nibName: "ProtectionMethodViewController", bundle: nil)
            rootVC.switchTo(viewController: protectionMethodVC)
            rootVC.bottomBarView.isHidden = false
            rootVC.homeButton.tintColor = .lightGray
            rootVC.timeOffButton.tintColor = .lightGray
            rootVC.settingButton.tintColor = .lightGray
        }
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}


extension PinCodeViewController {
    func setUpLabelsTexts() {
        switch mode {
        case .set:
            titleLabel.text = NSLocalizedString("pin_set_title", comment: "")
            hintLabel.text = NSLocalizedString("pin_set_hint", comment: "")
            nextButton.setTitle(NSLocalizedString("next_button_set", comment: ""), for: .normal)
            
        case .confirm:
            titleLabel.text = NSLocalizedString("pin_confirm_title", comment: "")
            hintLabel.text = NSLocalizedString("pin_confirm_hint", comment: "")
            nextButton.setTitle(NSLocalizedString("next_button_confirm", comment: ""), for: .normal)
            
        case .enter:
            titleLabel.text = NSLocalizedString("pin_enter_title", comment: "")
            hintLabel.text = NSLocalizedString("pin_enter_hint", comment: "")
            nextButton.setTitle(NSLocalizedString("next_button_enter", comment: ""), for: .normal)
        }
        
        forgetPasswardButton.setTitle(NSLocalizedString("forget_password", comment: ""), for: .normal)
    }
    
    func setUpplaceholderTextFields() {
        let placeholder = NSLocalizedString("digit_placeholder", comment: "")
        [firstNum, secoundNum, thirdNum, fouthNum].forEach {
            $0?.placeholder = placeholder
        }
    }
}



extension PinCodeViewController {
    func setUpTextFields() {
        let fields = [firstNum, secoundNum, thirdNum, fouthNum]
        fields.forEach {
            $0?.delegate = self
            $0?.keyboardType = .numberPad
            $0?.textAlignment = .center
            $0?.isSecureTextEntry = true
        }
        firstNum.becomeFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string.count <= 1 else { return false } // prevent pasting multiple digits
        if string.isEmpty { // backspace
            textField.text = ""
            switch textField {
            case secoundNum: firstNum.becomeFirstResponder()
            case thirdNum: secoundNum.becomeFirstResponder()
            case fouthNum: thirdNum.becomeFirstResponder()
            default: break
            }
            return false
        } else {
            textField.text = string
            switch textField {
            case firstNum: secoundNum.becomeFirstResponder()
            case secoundNum: thirdNum.becomeFirstResponder()
            case thirdNum: fouthNum.becomeFirstResponder()
            case fouthNum:
                fouthNum.resignFirstResponder()
            default: break
            }
            return false
        }
    }
}
