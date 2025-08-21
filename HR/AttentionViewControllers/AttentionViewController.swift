//
//  AttentionViewController.swift
//  HR
//
//  Created by Esther Elzek on 20/08/2025.
//

import UIKit

class AttentionViewController: UIViewController {

    @IBOutlet weak var attentionTltleLabel: UILabel! // "Attention"
    @IBOutlet weak var workedHoursLabel: UILabel!    // "You have spent 8:07"
    @IBOutlet weak var confirmQuestion: UILabel!     // "Are you sure you want to check out?"
    @IBOutlet weak var okButton: InspectableButton!
    @IBOutlet weak var cancelButton: InspectableButton!
    @IBOutlet weak var contentView: InspectableView!
    @IBOutlet var outSideView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadTexts()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOutsideTap(_:)))
        tapGesture.cancelsTouchesInView = false
        outSideView.addGestureRecognizer(tapGesture)
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
    @objc private func handleOutsideTap(_ gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: contentView)
        if !contentView.bounds.contains(touchPoint) {
            dismiss(animated: true, completion: nil)
        }
    }

    private func reloadTexts() {
        attentionTltleLabel.text = NSLocalizedString("attention_title", comment: "")
        workedHoursLabel.text = NSLocalizedString("worked_hours", comment: "")
        confirmQuestion.text = NSLocalizedString("confirm_checkout_question", comment: "")
        okButton.setTitle(NSLocalizedString("ok_button", comment: ""), for: .normal)
        cancelButton.setTitle(NSLocalizedString("cancel_button", comment: ""), for: .normal)
    }
    
    @IBAction func okButtonTapped(_ sender: Any) {
        print("✅ User confirmed checkout")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        print("❌ User canceled checkout")
        dismiss(animated: true, completion: nil)
    }
    
    
}
