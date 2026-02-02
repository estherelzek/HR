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
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var titlesBarView: UIStackView!
    private var currentVC: UIViewController?
    private var moreMenuView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        startApp()
        setUpTextFields()
        NotificationCenter.default.addObserver(self,selector: #selector(languageChanged),name: NSNotification.Name("LanguageChanged"),object: nil)
        NotificationCenter.default.addObserver(
               self,
               selector: #selector(openNotificationsFromPush),
               name: .openNotificationsScreen,
               object: nil
           )
     //   setupMoreMenu()
    }
    
    // MARK: - Bottom Bar Button Actions
    @IBAction func homeButoonTapped(_ sender: Any) {
        let homeVC = CheckingVC(nibName: "CheckingVC", bundle: nil)
        homeButton.tintColor = .purplecolor
        timeOffButton.tintColor = .lightGray
        settingButton.tintColor = .lightGray
        notificationButton.tintColor = .lightGray
        switchTo(viewController: homeVC)
    }
    
    @IBAction func timeOffButtonTapped(_ sender: Any) {
        let timeOffVC = TimeOffViewController(nibName: "TimeOffViewController", bundle: nil)
        homeButton.tintColor = .lightGray
        timeOffButton.tintColor = .purplecolor
        settingButton.tintColor = .lightGray
        notificationButton.tintColor = .lightGray
        switchTo(viewController: timeOffVC)
    }
    
    @IBAction func notificationButtonTapped(_ sender: Any) {
        let notificationVC = NotificationViewController(nibName: "NotificationViewController", bundle: nil)
        homeButton.tintColor = .lightGray
        timeOffButton.tintColor = .lightGray
        settingButton.tintColor = .lightGray
        notificationButton.tintColor = .purplecolor
        bottomBarView.isHidden = false
        titlesBarView.isHidden = false
        switchTo(viewController: notificationVC)
    }
    
    @IBAction func settingButtonTapped(_ sender: Any) {
        let settingVC = SettingScreenViewController(nibName: "SettingScreenViewController", bundle: nil)
        homeButton.tintColor = .lightGray
        timeOffButton.tintColor = .lightGray
        notificationButton.tintColor = .lightGray
        settingButton.tintColor = .purplecolor
        switchTo(viewController: settingVC)
        
        //
//        let settingVC = MainLunchViewController(nibName: "MainLunchViewController", bundle: nil)
//        homeButton.tintColor = .lightGray
//        timeOffButton.tintColor = .lightGray
//        notificationButton.tintColor = .lightGray
//        settingButton.tintColor = .purplecolor
//        switchTo(viewController: settingVC)
        //
     //   showMoreMenu()
    }
    
    func startApp() {
        // 🔴 IMPORTANT: do not override notification navigation
           if UserDefaults.standard.bool(forKey: "openedFromNotification") {
               print("🚀 Opened from notification → skip startApp navigation")
               return
           }

        let companyId = UserDefaults.standard.string(forKey: "companyIdKey") ?? ""
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
            titlesBarView.isHidden = true
            switchTo(viewController: checkVC)
           return
        }
        
        // 2️⃣ Check if employee token exists
        if token.isEmpty  {
            let loginVC = LogInViewController(nibName: "LogInViewController", bundle: nil)
            bottomBarView.isHidden = true
            titlesBarView.isHidden = true
            switchTo(viewController: loginVC)
        } else {
            if dontShowAgain {
                let checkVC = CheckingVC(nibName: "CheckingVC", bundle: nil)
                bottomBarView.isHidden = false
                titlesBarView.isHidden = false
                switchTo(viewController: checkVC)
            } else {
                if protectionMethod == "pin" {
                    let pinVC = PinCodeViewController(nibName: "PinCodeViewController", bundle: nil)
                    bottomBarView.isHidden = true
                    titlesBarView.isHidden = true
                    switchTo(viewController: pinVC)
                }else if protectionMethod == "fingerprint" {
                    let fingerprintVC = FingerprintViewController(nibName: "FingerprintViewController", bundle: nil)
                    bottomBarView.isHidden = true
                    titlesBarView.isHidden = true
                    switchTo(viewController: fingerprintVC)
                }  else if protectionMethod == "faceID" {
                        let fingerprintVC = FaceAuthenticationViewController(nibName: "FaceAuthenticationViewController", bundle: nil)
                        bottomBarView.isHidden = true
                        titlesBarView.isHidden = true
                        switchTo(viewController: fingerprintVC)
                } else {
                    let checkVC = CheckingVC(nibName: "CheckingVC", bundle: nil)
                    bottomBarView.isHidden = false
                    titlesBarView.isHidden = false
                    switchTo(viewController: checkVC)
                }
            }
        }
    }

    @objc func goToLogIn() {
        let loginVC = LogInViewController(nibName: "LogInViewController", bundle: nil)
        bottomBarView.isHidden = true
        titlesBarView.isHidden = true
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
        homeButton.setTitle(NSLocalizedString("", comment: ""), for: .normal)
        settingButton.setTitle(NSLocalizedString("", comment: ""), for: .normal)
        timeOffButton.setTitle(NSLocalizedString("", comment: ""), for: .normal)
    }

    @objc private func languageChanged() {
        setUpTextFields()
    }
    
    @objc private func openNotificationsFromPush(_ notification: Notification) {

        UserDefaults.standard.set(false, forKey: "openedFromNotification")

        let token = UserDefaults.standard.string(forKey: "employeeToken") ?? ""
        guard !token.isEmpty else {
            goToLogIn()
            return
        }

        let notificationVC = NotificationViewController(
            nibName: "NotificationViewController",
            bundle: nil
        )

        homeButton.tintColor = .lightGray
        timeOffButton.tintColor = .lightGray
        settingButton.tintColor = .lightGray
        notificationButton.tintColor = .purplecolor
        bottomBarView.isHidden = false
        titlesBarView.isHidden = false
        switchTo(viewController: notificationVC)
    }
    private func setupMoreMenu() {

        let settingsAction = UIAction(
            title: "Settings",
            image: UIImage(systemName: "gearshape")
        ) { [weak self] _ in
            self?.openSettings()
        }

        let lunchAction = UIAction(
            title: "Lunch",
            image: UIImage(systemName: "fork.knife")
        ) { [weak self] _ in
            self?.openLunch()
        }

        let menu = UIMenu(
            title: "",
            options: .displayInline,
            children: [settingsAction, lunchAction]
        )

        settingButton.menu = menu
        settingButton.showsMenuAsPrimaryAction = true // 🔥 tap opens menu
    }
    @objc private func openSettings() {
        let settingVC = SettingScreenViewController(
            nibName: "SettingScreenViewController",
            bundle: nil
        )

        homeButton.tintColor = .lightGray
        timeOffButton.tintColor = .lightGray
        notificationButton.tintColor = .lightGray
        settingButton.tintColor = .purplecolor

        switchTo(viewController: settingVC)
    }

    @objc private func openLunch() {
        let lunchVC = MainLunchViewController(
            nibName: "MainLunchViewController",
            bundle: nil
        )

        homeButton.tintColor = .lightGray
        timeOffButton.tintColor = .lightGray
        notificationButton.tintColor = .lightGray
        settingButton.tintColor = .purplecolor

        switchTo(viewController: lunchVC)
    }
//    private func showMoreMenu() {
//
//        // Prevent duplicates
//        if moreMenuView != nil {
//            hideMoreMenu()
//            return
//        }
//
//        let menuWidth: CGFloat = 160
//        let menuHeight: CGFloat = 100
//
//        let menuView = UIView()
//        menuView.backgroundColor = .white
//        menuView.layer.cornerRadius = 12
//        menuView.layer.shadowColor = UIColor.black.cgColor
//        menuView.layer.shadowOpacity = 0.15
//        menuView.layer.shadowRadius = 6
//        menuView.layer.shadowOffset = CGSize(width: 0, height: 4)
//
//        // Convert button frame to main view
//        let buttonFrame = settingButton.superview?.convert(settingButton.frame, to: view) ?? .zero
//
//        menuView.frame = CGRect(
//            x: buttonFrame.midX - menuWidth / 2,
//            y: buttonFrame.minY - menuHeight - 8,
//            width: menuWidth,
//            height: menuHeight
//        )
//
//        // Buttons
//        let settingsBtn = createMenuButton(title: "Settings", y: 0)
//        settingsBtn.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
//
//        let lunchBtn = createMenuButton(title: "Lunch", y: 50)
//        lunchBtn.addTarget(self, action: #selector(openLunch), for: .touchUpInside)
//
//        menuView.addSubview(settingsBtn)
//        menuView.addSubview(lunchBtn)
//
//        view.addSubview(menuView)
//        moreMenuView = menuView
//
//        // Animate
//        menuView.alpha = 0
//        menuView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
//
//        UIView.animate(withDuration: 0.2) {
//            menuView.alpha = 1
//            menuView.transform = .identity
//        }
//
//        addDismissTap()
//    }
    private func createMenuButton(title: String, y: CGFloat) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.frame = CGRect(x: 12, y: y, width: 136, height: 50)
        return button
    }
    private func hideMoreMenu() {
        UIView.animate(withDuration: 0.15, animations: {
            self.moreMenuView?.alpha = 0
        }) { _ in
            self.moreMenuView?.removeFromSuperview()
            self.moreMenuView = nil
        }
    }
    private func addDismissTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func backgroundTapped() {
        hideMoreMenu()
    }

}
