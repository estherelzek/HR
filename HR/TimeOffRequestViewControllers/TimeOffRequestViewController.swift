//
//  TimeOffRequestViewController.swift
//  HR
//
//  Created by Esther Elzek on 26/08/2025.
//

import UIKit

class TimeOffRequestViewController: UIViewController {
    
    @IBOutlet weak var timeOffRequest: UILabel!
    @IBOutlet weak var typeOffType: UILabel!
    @IBOutlet weak var selectLeaveTypeTextField: UITextField!
    @IBOutlet weak var datesLabel: UILabel!
    @IBOutlet weak var startDateCalender: UITextField!
    @IBOutlet weak var endDateCalender: UITextField!
    @IBOutlet weak var MorningOrNightTextField: UITextField!
    @IBOutlet weak var halfDayButton: UIButton!
    @IBOutlet weak var customHoursButton: UIButton!
    @IBOutlet weak var durationTitleLabel: UILabel!
    @IBOutlet weak var durationCountLabel: UILabel!
    @IBOutlet weak var addDescriptionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocalization()
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
    }
    
    @IBAction func halfDayButtonTapped(_ sender: Any) {
    }
    
    @IBAction func customHourButtonTapped(_ sender: Any) {
    }
}

extension TimeOffRequestViewController{
    private func setupLocalization() {
        timeOffRequest.text = NSLocalizedString("TimeOffRequest_Title", comment: "")
        typeOffType.text = NSLocalizedString("TimeOffRequest_Type", comment: "")
        selectLeaveTypeTextField.placeholder = NSLocalizedString("TimeOffRequest_SelectLeave", comment: "")
        datesLabel.text = NSLocalizedString("TimeOffRequest_Dates", comment: "")
        startDateCalender.placeholder = NSLocalizedString("TimeOffRequest_StartDate", comment: "")
        endDateCalender.placeholder = NSLocalizedString("TimeOffRequest_EndDate", comment: "")
        MorningOrNightTextField.placeholder = NSLocalizedString("TimeOffRequest_MorningOrNight", comment: "")
        halfDayButton.setTitle(NSLocalizedString("TimeOffRequest_HalfDay", comment: ""), for: .normal)
        customHoursButton.setTitle(NSLocalizedString("TimeOffRequest_CustomHours", comment: ""), for: .normal)
        durationTitleLabel.text = NSLocalizedString("TimeOffRequest_Duration", comment: "")
        addDescriptionTextField.placeholder = NSLocalizedString("TimeOffRequest_AddDescription", comment: "")
    }
}
