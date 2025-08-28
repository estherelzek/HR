//
//  AttentionViewController.swift
//  HR
//
//  Created by Esther Elzek on 20/08/2025.
//

import UIKit

class AttentionViewController: UIViewController {

    @IBOutlet weak var attentionTltleLabel: UILabel!
    @IBOutlet weak var workedHoursLabel: UILabel!
    @IBOutlet weak var confirmQuestion: UILabel!
    @IBOutlet weak var okButton: InspectableButton!
    @IBOutlet weak var cancelButton: InspectableButton!
    @IBOutlet weak var contentView: InspectableView!
    @IBOutlet var outSideView: UIView!

    var onConfirm: (() -> Void)?  // callback
    var workedHoursText: String? {
        didSet {
            if isViewLoaded {
                workedHoursLabel.text = String(
                    format: NSLocalizedString("worked_hours_format", comment: ""),
                    workedHoursText ?? "0"
                )
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOutsideTap(_:)))
        tapGesture.cancelsTouchesInView = false
        outSideView.addGestureRecognizer(tapGesture)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLanguageChange),
            name: NSNotification.Name("LanguageChanged"),
            object: nil
        )
        if let hoursText = workedHoursText {
            workedHoursLabel.text = String(
                format: NSLocalizedString("worked_hours_format", comment: ""),
                hoursText
            )
        }
        reloadTexts()
    }

    @objc private func handleLanguageChange() {
        reloadTexts()
    }

    private func reloadTexts() {
        attentionTltleLabel.text = NSLocalizedString("attention_title", comment: "")

        if let hoursText = workedHoursText {
            workedHoursLabel.text = String(
                format: NSLocalizedString("worked_hours_format", comment: ""),
                hoursText
            )
        }

        confirmQuestion.text = NSLocalizedString("confirm_checkout_question", comment: "")
        okButton.setTitle(NSLocalizedString("ok_button", comment: ""), for: .normal)
        cancelButton.setTitle(NSLocalizedString("cancel_button", comment: ""), for: .normal)
    }

    @objc private func handleOutsideTap(_ gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: contentView)
        if !contentView.bounds.contains(touchPoint) {
            dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func okButtonTapped(_ sender: Any) {
        dismiss(animated: true) { [weak self] in
            self?.onConfirm?()
        }
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
