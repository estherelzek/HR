//
//  TimeOffRequestViewController.swift
//  HR
//
//  Created by Esther Elzek on 26/08/2025.
//

import UIKit

class TimeOffRequestViewController: UIViewController {
    
    @IBOutlet weak var dateStack: UIStackView!
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
    @IBOutlet weak var contentView: InspectableView!
    @IBOutlet var ouSideView: UIView!
    
    // MARK: - Data Sources
    var leaveTypes: [LeaveType] = []  // API fills this
    var filteredLeaveTypes: [LeaveType] = []
    let morningNightOptions = ["Morning", "Night"]
    private let leaveTypePicker = UIPickerView()
    private let morningNightPicker = UIPickerView()
    private let startDatePicker = UIDatePicker()
    private let endDatePicker = UIDatePicker()
    let leaveDurationVM = LeaveDurationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOutsideTap(_:)))
        tapGesture.cancelsTouchesInView = false
        ouSideView.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self,selector: #selector(languageChanged),name: NSNotification.Name("LanguageChanged"),object: nil)
        setUpTexts()
        setupPickers()
        print("self.filteredLeaveTypes: \(self.filteredLeaveTypes)")
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func halfDayButtonTapped(_ sender: Any) {
        dateStack.isHidden = false
        MorningOrNightTextField.isHidden = false
        endDateCalender.isHidden = true
    }
    
    @IBAction func customHourButtonTapped(_ sender: Any) {
        dateStack.isHidden = false
        startDateCalender.isHidden = false
        endDateCalender.isHidden = false
        MorningOrNightTextField.isHidden = true
    }
    
    @objc private func handleOutsideTap(_ gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: contentView)
        if !contentView.bounds.contains(touchPoint) {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func languageChanged() {
        setUpTexts()
    }
    //request unit half , request unit hours should be boolean
   func getDuration() {
        guard
            let token = UserDefaults.standard.string(forKey: "employeeToken"), // 🔑 from login/session
            let leaveTypeName = selectLeaveTypeTextField.text,
            let leaveTypeId = filteredLeaveTypes.first(where: { $0.name == leaveTypeName })?.id,
            let startDate = startDateCalender.text,
            let endDate = endDateCalender.text
        else {
            print("❌ Missing required fields")
            return
        }

        let apiDateFormatter = DateFormatter()
        apiDateFormatter.dateFormat = "MM-dd-yyyy"

        let uiFormatter = DateFormatter()
        uiFormatter.dateStyle = .medium

        guard
            let startDateObj = uiFormatter.date(from: startDate),
            let endDateObj = uiFormatter.date(from: endDate)
        else {
            print("❌ Invalid date format")
            return
        }

        let requestDateFrom = apiDateFormatter.string(from: startDateObj)
        let requestDateTo = apiDateFormatter.string(from: endDateObj)
        let requestDateFromPeriod = MorningOrNightTextField.text?.lowercased() == "morning" ? "am" : "pm"
       let isHalfDay = halfDayButton.isSelected ? true : false
        let isCustomHours = customHoursButton.isSelected ? true : false

        leaveDurationVM.fetchLeaveDuration(
            token: token,
            leaveTypeId: leaveTypeId,
            requestDateFrom: requestDateFrom,
            requestDateTo: requestDateTo,
            requestDateFromPeriod: requestDateFromPeriod,
            requestUnitHalf: isHalfDay,
            requestHourFrom: nil, // you can bind from extra fields if you add time pickers
            requestHourTo: nil,
            requestUnitHours: isCustomHours
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self?.durationTitleLabel.text = "Duration"
                    self?.durationCountLabel.text = "\(data.days ?? 0) days (\(data.hours ?? 0) hrs)"
                    print("✅ Duration: \(data.days ?? 0) days, \(data.hours ?? 0) hours")
                case .failure(let error):
                    self?.durationCountLabel.text = "Error"
                    print("❌ Error fetching leave duration: \(error)")
                }
            }
        }
    }
}

extension TimeOffRequestViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func setupPickers() {
        leaveTypePicker.delegate = self
        leaveTypePicker.dataSource = self
        selectLeaveTypeTextField.inputView = leaveTypePicker
        morningNightPicker.delegate = self
        morningNightPicker.dataSource = self
        MorningOrNightTextField.inputView = morningNightPicker
        morningNightPicker.selectRow(0, inComponent: 0, animated: false)
        MorningOrNightTextField.text = pickerView(morningNightPicker, titleForRow: 0, forComponent: 0)
        startDatePicker.datePickerMode = .date
        endDatePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            startDatePicker.preferredDatePickerStyle = .wheels
            endDatePicker.preferredDatePickerStyle = .wheels
        }
        startDateCalender.inputView = startDatePicker
        endDateCalender.inputView = endDatePicker
        startDatePicker.date = Date()
        endDatePicker.date = Date()
        startDateCalender.text = formatDate(Date())
        endDateCalender.text = formatDate(Date())

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        toolbar.setItems([done], animated: true)
        selectLeaveTypeTextField.inputAccessoryView = toolbar
        MorningOrNightTextField.inputAccessoryView = toolbar
        startDateCalender.inputAccessoryView = toolbar
        endDateCalender.inputAccessoryView = toolbar
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    @objc func doneTapped() {
        if startDateCalender.isFirstResponder {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            startDateCalender.text = formatter.string(from: startDatePicker.date)
        } else if endDateCalender.isFirstResponder {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            endDateCalender.text = formatter.string(from: endDatePicker.date)
        }
        getDuration()
        view.endEditing(true)
    }

    // MARK: PickerView DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == leaveTypePicker {
            return filteredLeaveTypes.count
        } else {
            return morningNightOptions.count
        }
    }

    // MARK: PickerView Delegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == leaveTypePicker {
            return filteredLeaveTypes[row].name
        } else {
            return morningNightOptions[row]
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == leaveTypePicker {
            selectLeaveTypeTextField.text = filteredLeaveTypes[row].name
            if filteredLeaveTypes[row].name != "annual leave" {
                customHoursButton.isHidden = false
                dateStack.isHidden = false
                startDateCalender.isHidden = false
                endDateCalender.isHidden = false
                MorningOrNightTextField.isHidden = true
            }
            else {
                customHoursButton.isHidden = true
                dateStack.isHidden = false
                startDateCalender.isHidden = false
                endDateCalender.isHidden = false
                MorningOrNightTextField.isHidden = true
            }
        } else {
            MorningOrNightTextField.text = morningNightOptions[row]
        }
        doneTapped()
    }
}

extension TimeOffRequestViewController{
    private func setUpTexts() {
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
