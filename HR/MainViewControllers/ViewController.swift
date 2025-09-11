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
        if let token = UserDefaults.standard.string(forKey: "employeeToken"),
           !token.isEmpty {
            let checkVC = CheckingViewController(nibName: "CheckingViewController", bundle: nil)
            homeButton.tintColor = .purplecolor
            timeOffButton.tintColor = .lightGray
            settingButton.tintColor = .lightGray
            switchTo(viewController: checkVC)
        } else {
            let loginVC = LogInViewController(nibName: "LogInViewController", bundle: nil)
            homeButton.tintColor = .purplecolor
            timeOffButton.tintColor = .lightGray
            settingButton.tintColor = .lightGray
            switchTo(viewController: loginVC)
            bottomBarView.isHidden = true
        }
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
}
