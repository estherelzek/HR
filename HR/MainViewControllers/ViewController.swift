//
//  ViewController.swift
//  HR
//
//  Created by Esther Elzek on 07/08/2025.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var timeOffButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var bottomBarView: UIStackView!
    
    private var currentVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startApp()
        setUpTextFields()
        
        NotificationCenter.default.addObserver(self,selector: #selector(languageChanged),name: NSNotification.Name("LanguageChanged"),object: nil)
    }
    
    // MARK: - Bottom Bar Button Actions
    @IBAction func homeButoonTapped(_ sender: Any) {
        let homeVC = CheckingViewController(nibName: "CheckingViewController", bundle: nil)
        homeButton.tintColor = .purplecolor
        timeOffButton.tintColor = .lightGray
        settingButton.tintColor = .lightGray
        switchTo(viewController: homeVC)
    }
    
    @IBAction func timeOffButtonTapped(_ sender: Any) {
        let timeOffVC = TimeOffViewController(nibName: "TimeOffViewController", bundle: nil)
        homeButton.tintColor = .lightGray
        timeOffButton.tintColor = .purplecolor
        settingButton.tintColor = .lightGray
        switchTo(viewController: timeOffVC)
    }
    
    @IBAction func settingButtonTapped(_ sender: Any) {
        let settingVC = SettingScreenViewController(nibName: "SettingScreenViewController", bundle: nil)
        homeButton.tintColor = .lightGray
        timeOffButton.tintColor = .lightGray
        settingButton.tintColor = .purplecolor
        switchTo(viewController: settingVC)
    }
    func startApp() {
        let companyId = UserDefaults.standard.string(forKey: "companyId") ?? ""
        let token = UserDefaults.standard.string(forKey: "employeeToken") ?? ""
        let dontShowAgain = UserDefaults.standard.bool(forKey: "dontShowProtectionScreen") // store as Bool, not "true"/"false" string
        let protectionMethod = UserDefaults.standard.string(forKey: "selectedProtectionMethod") ?? ""
        
        print("companyId: \(companyId)")
        print("token: \(token)")
        print("dontShowAgain: \(dontShowAgain)")
        print("protectionMethod: \(protectionMethod)")
        
        // 1️⃣ Check if companyId exists
        if companyId.isEmpty  {
            print("companyId is empty , so we go to scan view controller")
            let checkVC = ScanAndInfoViewController(nibName: "ScanAndInfoViewController", bundle: nil)
            bottomBarView.isHidden = true
            switchTo(viewController: checkVC)
           return
        }
        
        // 2️⃣ Check if employee token exists
        if token.isEmpty  {
            let loginVC = LogInViewController(nibName: "LogInViewController", bundle: nil)
            bottomBarView.isHidden = true
            switchTo(viewController: loginVC)
        } else {
            if dontShowAgain {
                let checkVC = CheckingViewController(nibName: "CheckingViewController", bundle: nil)
                bottomBarView.isHidden = true
                switchTo(viewController: checkVC)
            } else {
                if protectionMethod == "pin" {
                    let pinVC = PinCodeViewController(nibName: "PinCodeViewController", bundle: nil)
                    bottomBarView.isHidden = true
                    switchTo(viewController: pinVC)
                }else if protectionMethod == "fingerprint" {
                    let fingerprintVC = FingerprintViewController(nibName: "FingerprintViewController", bundle: nil)
                    bottomBarView.isHidden = true
                    switchTo(viewController: fingerprintVC)
                } else {
                    let checkVC = CheckingViewController(nibName: "CheckingViewController", bundle: nil)
                    bottomBarView.isHidden = false
                    switchTo(viewController: checkVC)
                }
            }
        }
    }

    @objc func goToLogIn() {
        let loginVC = LogInViewController(nibName: "LogInViewController", bundle: nil)
        bottomBarView.isHidden = true
        switchTo(viewController: loginVC)
    }
    
    
    func switchTo(viewController newVC: UIViewController) {
            if let current = currentVC {
                current.willMove(toParent: nil)
                current.view.removeFromSuperview()
                current.removeFromParent()
            }
            addChild(newVC)
            newVC.view.frame = contentView.bounds
            contentView.addSubview(newVC.view)
            newVC.didMove(toParent: self)
            currentVC = newVC
        }
    
    func setUpTextFields() {
        homeButton.setTitle(NSLocalizedString("Home", comment: ""), for: .normal)
        settingButton.setTitle(NSLocalizedString("Settings", comment: ""), for: .normal)
        timeOffButton.setTitle(NSLocalizedString("timeOff", comment: ""), for: .normal)
    }

    @objc private func languageChanged() {
        setUpTextFields()
    }
}
