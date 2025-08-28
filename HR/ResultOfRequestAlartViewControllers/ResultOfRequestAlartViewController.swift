//
//  ResultOfRequestAlartViewController.swift
//  HR
//
//  Created by Esther Elzek on 11/08/2025.
//

import UIKit

class ResultOfRequestAlartViewController: UIViewController {

    @IBOutlet weak var tilteLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var requestData: UIStackView!
    @IBOutlet weak var coloredButton: InspectableButton!
    @IBOutlet weak var ActionButton: InspectableButton!
    @IBOutlet weak var contentView: InspectableView!
    @IBOutlet var outSideView: UIView!
    @IBOutlet weak var numberOfAnnualLeaveLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTexts()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOutsideTap(_:)))
        tapGesture.cancelsTouchesInView = false
        outSideView.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self,selector: #selector(languageChanged),name: NSNotification.Name("LanguageChanged"),object: nil)
    }

    @IBAction func ActionButton(_ sender: Any) {
        // handle delete action
    }
    
    @objc private func handleOutsideTap(_ gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: contentView)
        if !contentView.bounds.contains(touchPoint) {
            dismiss(animated: true, completion: nil)
        }
    }

    func setUpTexts() {
        tilteLabel.text = NSLocalizedString("pending_approval", comment: "")
        ActionButton.setTitle(NSLocalizedString("delete", comment: ""), for: .normal)
        let formatter = DateFormatter()
        if LanguageManager.shared.currentLanguage() == "ar" {
            formatter.locale = Locale(identifier: "ar")
        } else {
            formatter.locale = Locale(identifier: "en")
        }
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        dateLabel.text = formatter.string(from: Date())
        let leaveDays: Double = 1.0
        numberOfAnnualLeaveLabel.text = String(format: NSLocalizedString("annual_leave_days", comment: ""), leaveDays)
    }
    
    @objc private func languageChanged() {
        setUpTexts()
       }
    

}
