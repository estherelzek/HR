//
//  CheckingViewController.swift
//  HR
//
//  Created by Esther Elzek on 20/08/2025.
//

import UIKit

class CheckingViewController: UIViewController {
    
    @IBOutlet weak var titleOfCheckingInOrOut: UILabel!
    @IBOutlet weak var discreptionOfCurrecntAttendence: UILabel!
    @IBOutlet weak var checkingButton: InspectableButton!
   
    private var isCheckedIn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadTexts()
        
        // listen for language change
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLanguageChange),
            name: NSNotification.Name("LanguageChanged"),
            object: nil
        )
    }
    
    @objc private func handleLanguageChange() {
        reloadTexts()
    }
    
    @IBAction func checkingButtonTapped(_ sender: Any) {
        isCheckedIn.toggle() // flip state
        reloadTexts()
    }
    
    private func reloadTexts() {
        if isCheckedIn {
            // ✅ بعد ما المستخدم يعمل Check-In
            titleOfCheckingInOrOut.text = NSLocalizedString("checked_in_title", comment: "")
            discreptionOfCurrecntAttendence.text = NSLocalizedString("checked_in_description", comment: "")
            checkingButton.setTitle(NSLocalizedString("check_out_button", comment: ""), for: .normal)
        } else {
            // ❌ لسه ما عملش Check-In أو عمل Check-Out
            titleOfCheckingInOrOut.text = NSLocalizedString("checked_out_title", comment: "")
            discreptionOfCurrecntAttendence.text = NSLocalizedString("checked_out_description", comment: "")
            checkingButton.setTitle(NSLocalizedString("check_in_button", comment: ""), for: .normal)
        }
        
        // 🔄 اضبط الاتجاه حسب اللغة
        let isArabic = LanguageManager.shared.currentLanguage() == "ar"
        [titleOfCheckingInOrOut, discreptionOfCurrecntAttendence].forEach {
            $0?.semanticContentAttribute = isArabic ? .forceRightToLeft : .forceLeftToRight
            $0?.textAlignment = isArabic ? .right : .left
        }
        checkingButton.semanticContentAttribute = isArabic ? .forceRightToLeft : .forceLeftToRight
    }
}
