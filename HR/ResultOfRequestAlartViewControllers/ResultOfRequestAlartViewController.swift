//
//  ResultOfRequestAlartViewController.swift
//  HR
//
//  Created by Esther Elzek on 11/08/2025.
//

import UIKit
import Combine

class ResultOfRequestAlartViewController: UIViewController {

    @IBOutlet weak var tilteLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var requestData: UIStackView!
    @IBOutlet weak var coloredButton: InspectableButton!
    @IBOutlet weak var ActionButton: InspectableButton!
    @IBOutlet weak var contentView: InspectableView!
    @IBOutlet var outSideView: UIView!
    @IBOutlet weak var numberOfAnnualLeaveLabel: UILabel!
    
    private let viewModel = EmployeeUnlinkTimeOffViewModel()
    var leaveId: Int?
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTexts()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOutsideTap(_:)))
        tapGesture.cancelsTouchesInView = false
        outSideView.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self,selector: #selector(languageChanged),name: NSNotification.Name("LanguageChanged"),object: nil)
    }

    @IBAction func ActionButton(_ sender: Any) {
        if let token = UserDefaults.standard.string(forKey: "employeeToken") {
            print("leaveId: \(self.leaveId ?? 0)")
            viewModel.unlinkDraftLeave(token: token, leaveId: self.leaveId ?? 0)
        }
        viewModel.$success
            .dropFirst()   // 🚀 Ignore the initial value
            .sink { [weak self] isSuccess in
                guard let self = self else { return }
                print("isSuccess: \(isSuccess)")
                if isSuccess {
                    print("in success block")
                    self.showAlert(
                        title: "Success",
                        message: self.viewModel.apiMessage ?? "Action completed"
                    ) {
                        self.dismiss(animated: true)
                    }
                } else {
                    print("in error block")
                    self.showAlert(
                        title: "Alert",
                        message: self.viewModel.apiMessage ?? "It already Approved"
                    )
                }
            }
            .store(in: &cancellables)
    }

    
    @objc private func handleOutsideTap(_ gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: contentView)
        if !contentView.bounds.contains(touchPoint) {
            dismiss(animated: true, completion: nil)
        }
    }

    func setUpTexts() {
        tilteLabel.text = NSLocalizedString("pending_approval", comment: "")
        ActionButton.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
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
    
    func fillTextFields(record: DailyRecord){
        dateLabel.text = "\(record.startDate) : \(record.endDate)"
        numberOfAnnualLeaveLabel.text = "\(record.leaveType): \(record.durationDays)"
    }
    
    func fillTextFields(record: LeaveRecord) {
        if let daily = record as? DailyRecord {
            dateLabel.text = "\(daily.startDate) : \(daily.endDate)"
            numberOfAnnualLeaveLabel.text = "\(daily.leaveType): \(daily.durationDays)"
            leaveId =  daily.leaveID
            print("Daily leave for \(daily.durationDays) days")
        } else if let hourly = record as? HourlyRecord {
            dateLabel.text = "\(hourly.startDate) : \(hourly.endDate)"
            numberOfAnnualLeaveLabel.text = "\(hourly.leaveType): \(hourly.durationHours)"
            leaveId =  hourly.leaveID
            print("Hourly leave for \(hourly.leaveID) hours")
        }
    }
}
