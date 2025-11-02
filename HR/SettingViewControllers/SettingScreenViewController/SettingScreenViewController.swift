//
//  SettingScreenViewController.swift
//  HR
//
//  Created by Esther Elzek on 18/08/2025.
//

import UIKit

protocol SettingScreenCellDelegate: AnyObject {
    func didTapDropdown(in cell: SettingScreenTableViewCell)
}

class SettingScreenViewController: UIViewController, DarkModeTableViewCellDelegate {
   
    @IBOutlet weak var generalStettingTableView: InspectableTableView!
    @IBOutlet weak var securityTabelView: InspectableTableView!
    @IBOutlet weak var accountTabelView: InspectableTableView!
    @IBOutlet weak var generalLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var securityLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    var isLanguageExpanded = false
    var selectedLanguage: (String, String)? = nil
    let languages = [(NSLocalizedString("english", comment: ""), "english"),(NSLocalizedString("arabic", comment: ""), "egypt")]
    let generalItemsKeys = [("change_company", "building.2"),("language", "globe"),("dark_mode", "moon.fill")]
    let securityItemsKeys = [("change_protection", "lock.fill")]
    let accountItemsKeys = [("logout", "rectangle.portrait.and.arrow.right")]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableViews()
        reloadTexts()
        NotificationCenter.default.addObserver(self,selector: #selector(handleLanguageChange),name: NSNotification.Name("LanguageChanged"),object: nil)
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkModeEnabled")
        if let window = UIApplication.shared.windows.first {
            window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        }
    }
   
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @objc private func handleLanguageChange() {
        reloadTexts()
    }
    
    func darkModeSwitchChanged(isOn: Bool) {
        if let window = UIApplication.shared.windows.first {
            window.overrideUserInterfaceStyle = isOn ? .dark : .light
        }
        UserDefaults.standard.set(isOn, forKey: "isDarkModeEnabled")
        UserDefaults.standard.synchronize()
    }
    
    private func setupTableViews() {
        [generalStettingTableView, securityTabelView, accountTabelView].forEach { tableView in
            tableView?.delegate = self
            tableView?.dataSource = self
            tableView?.register(
                UINib(nibName: "SettingScreenTableViewCell", bundle: nil),
                forCellReuseIdentifier: "SettingScreenTableViewCell"
            )
            tableView?.register(
                UINib(nibName: "DarkModeTableViewCell", bundle: nil),
                forCellReuseIdentifier: "DarkModeTableViewCell"
            )
            tableView?.tableFooterView = UIView() // remove empty cells
        }
    }
}

extension SettingScreenViewController: UITableViewDelegate, UITableViewDataSource, SettingScreenTableViewCellDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == generalStettingTableView {
            return generalItemsKeys.count + (isLanguageExpanded ? languages.count : 0)
        } else if tableView == securityTabelView {
            return securityItemsKeys.count
        } else if tableView == accountTabelView {
            return accountItemsKeys.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rows: Int
        if tableView == generalStettingTableView {
            rows = generalItemsKeys.count + (isLanguageExpanded ? languages.count : 0)
        } else if tableView == securityTabelView {
            rows = securityItemsKeys.count
        } else if tableView == accountTabelView {
            rows = accountItemsKeys.count
        } else {
            rows = 1
        }
        guard rows > 0 else { return 44 }
        return tableView.frame.height / CGFloat(rows)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var item: SettingItem
        
        if tableView == generalStettingTableView {
            if indexPath.row <= 1 {
                let general = generalItemsKeys[indexPath.row]
                item = SettingItem(titleKey: general.0,iconName: general.1,isDropdownVisible: indexPath.row == 1,isDarkModeRow: false)
            } else if isLanguageExpanded && indexPath.row > 1 && indexPath.row <= 1 + languages.count {
                let lang = languages[indexPath.row - 2]
                item = SettingItem(titleKey: lang.0,iconName: lang.1,isDropdownVisible: false,isDarkModeRow: false)
            } else {
                let adjustedIndex = indexPath.row - (isLanguageExpanded ? languages.count : 0)
                let general = generalItemsKeys[adjustedIndex]
                item = SettingItem(titleKey: general.0,iconName: general.1,isDropdownVisible: false,isDarkModeRow: general.0 == "dark_mode")
            }
        } else if tableView == securityTabelView {
            let security = securityItemsKeys[indexPath.row]
            item = SettingItem(titleKey: security.0,iconName: security.1,isDropdownVisible: false,isDarkModeRow: false)
        } else {
            let account = accountItemsKeys[indexPath.row]
            item = SettingItem(titleKey: account.0,iconName: account.1,isDropdownVisible: false,isDarkModeRow: false)
        }
        if item.isDarkModeRow {
            guard let darkModeCell = tableView.dequeueReusableCell(
                withIdentifier: "DarkModeTableViewCell",for: indexPath) as? DarkModeTableViewCell else {
                return UITableViewCell()
            }
            darkModeCell.delegate = self
            darkModeCell.configure(with: item, trait: traitCollection)
            return darkModeCell
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingScreenTableViewCell",for: indexPath) as? SettingScreenTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.configure(with: item, trait: traitCollection)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if tableView == generalStettingTableView {
            if isLanguageExpanded && indexPath.row > 1 && indexPath.row <= 1 + languages.count {
                let lang = languages[indexPath.row - 2]
                selectedLanguage = lang
                isLanguageExpanded = false
                let code = (lang.0 == NSLocalizedString("english", comment: "")) ? "en" : "ar"
                LanguageManager.shared.setLanguage(code)
                tableView.reloadData()
            } else {
                let adjustedIndex = indexPath.row - (isLanguageExpanded && indexPath.row > 1 + languages.count ? languages.count : 0)
                switch adjustedIndex {
                case 0:
                    let alert = UIAlertController(
                        title: NSLocalizedString("changeCompany_title", comment: ""),
                        message: NSLocalizedString("changeCompany_message", comment: ""),
                        preferredStyle: .alert
                    )

                    let okAction = UIAlertAction(title: NSLocalizedString("logout_ok", comment: ""), style: .default) { _ in
                        self.goToScanVC()
                    }
                    okAction.setValue(UIColor.purplecolor, forKey: "titleTextColor")
                    let cancelAction = UIAlertAction(title: NSLocalizedString("logout_cancel", comment: ""), style: .cancel)
                    cancelAction.setValue(UIColor.systemRed, forKey: "titleTextColor")
                    alert.addAction(okAction)
                    alert.addAction(cancelAction)
                    present(alert, animated: true)
                case 1: break
                case 2: print("Dark Mode tapped") // handled by switch now
                default: break
                }
            }
        } else if tableView == securityTabelView {
            switch indexPath.row {
            case 0: navigateToChangeProtectionViewController()
            default: break
            }
        } else if tableView == accountTabelView {
            let alert = UIAlertController(
                title: NSLocalizedString("logout_title", comment: ""),
                message: NSLocalizedString("logout_message", comment: ""),
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: NSLocalizedString("logout_ok", comment: ""), style: .default) { _ in
                UserDefaults.standard.removeObject(forKey: "employeeToken")
                UserDefaults.standard.removeObject(forKey: "dontShowProtectionScreen")
                UserDefaults.standard.removeObject(forKey: "selectedProtectionMethod")
                self.goToLogInViewController()
            }
            okAction.setValue(UIColor.purplecolor, forKey: "titleTextColor")
            let cancelAction = UIAlertAction(title: NSLocalizedString("logout_cancel", comment: ""), style: .cancel)
            cancelAction.setValue(UIColor.systemRed, forKey: "titleTextColor")
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            present(alert, animated: true)
        }
    }

    func didTapDropdown(in cell: SettingScreenTableViewCell) {
        guard let indexPath = generalStettingTableView.indexPath(for: cell) else { return }
        if indexPath.row == 1 { // Language row only
            isLanguageExpanded.toggle()
            generalStettingTableView.reloadData()
        }
    }
}

extension SettingScreenViewController: Localizable {
    func reloadTexts() {
        generalLabel.text = NSLocalizedString("general_settings", comment: "")
        securityLabel.text = NSLocalizedString("security_settings", comment: "")
        accountLabel.text = NSLocalizedString("account_settings", comment: "")
        titleLabel.text = NSLocalizedString("settings_screen", comment: "")
        generalStettingTableView.reloadData()
        securityTabelView.reloadData()
        accountTabelView.reloadData()
    }
  
    func navigateToChangeProtectionViewController(){
        let protectionMethod = UserDefaults.standard.string(forKey: "selectedProtectionMethod") ?? ""
        if protectionMethod == "pin" {
            let pinVC = PinCodeViewController(nibName: "PinCodeViewController", bundle: nil)
            pinVC.modalPresentationStyle = .fullScreen
            pinVC.mode = .enter
            pinVC.needToChangeProtectionMethod = true
            self.present(pinVC, animated: true)
            
        } else if protectionMethod == "fingerprint" {
            let fingerprintVC = FingerprintViewController(nibName: "FingerprintViewController", bundle: nil)
            fingerprintVC.modalPresentationStyle = .fullScreen
            self.present(fingerprintVC, animated: true)
        } else {
            let protectionMethodVC = ProtectionMethodViewController(nibName: "ProtectionMethodViewController",bundle: nil)
            protectionMethodVC.modalPresentationStyle = .fullScreen
            self.present(protectionMethodVC, animated: true)
     }
   }
}

extension SettingScreenViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            generalStettingTableView.reloadData()
            
        }
    }
}
