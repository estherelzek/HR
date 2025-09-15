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
    @IBOutlet weak var saveButtonTapped: InspectableButton!
    @IBOutlet weak var clockFrom: UITextField!
    @IBOutlet weak var ClockTo: UITextField!
    @IBOutlet weak var clockLabel: UILabel!
    @IBOutlet weak var clockStackView: UIStackView!
    @IBOutlet weak var saveButton: InspectableButton!
    // MARK: - Data Sources
    var leaveTypes: [LeaveType] = []  // API fills this
    var filteredLeaveTypes: [LeaveType] = []
    let morningNightOptions = ["Morning", "Night"]
    private let leaveTypePicker = UIPickerView()
    private let morningNightPicker = UIPickerView()
    private let startDatePicker = UIDatePicker()
    private let endDatePicker = UIDatePicker()
    private let clockFromPicker = UIDatePicker()
    private let clockToPicker = UIDatePicker()
    let leaveDurationVM = LeaveDurationViewModel()
    let viewModel = TimeOffRequestViewModel()
    let parentobject = TimeOffViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOutsideTap(_:)))
        tapGesture.cancelsTouchesInView = false
        ouSideView.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self,selector: #selector(languageChanged),name: NSNotification.Name("LanguageChanged"),object: nil)
        setUpTexts()
        setupPickers()
        setUpAnnualMode()
        halfDayButton.backgroundColor = .clear
        customHoursButton.backgroundColor = .clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let lang = LanguageManager.shared.currentLanguage()
        print("🔄 ViewWillAppear - Current language: \(lang)")
        setupPickers()
        print("startDateCalender.text : \(startDateCalender.text ?? "")")
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func halfDayButtonTapped(_ sender: Any) {
        halfDayButton.isSelected.toggle()
        if halfDayButton.isSelected {
            customHoursButton.isSelected = false
        }
        if halfDayButton.isSelected {
            setUpHalfDayMode()
        } else {
            setUpAnnualMode()
        }
    }

    @IBAction func customHourButtonTapped(_ sender: Any) {
        customHoursButton.isSelected.toggle()
        if customHoursButton.isSelected {
            halfDayButton.isSelected = false
        }
        if customHoursButton.isSelected {
            setUpCustomHoursMode()
        } else {
            setUpAnnualMode()
        }
    }
    
    @objc private func handleOutsideTap(_ gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: contentView)
        if !contentView.bounds.contains(touchPoint) {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard
            let token = UserDefaults.standard.string(forKey: "employeeToken"),
            let leaveTypeName = selectLeaveTypeTextField.text,
            let leaveTypeId = filteredLeaveTypes.first(where: { $0.name == leaveTypeName })?.id,
            let startDate = startDateCalender.text,
            let endDate = endDateCalender.text
        else {
            print("❌ Missing required fields")
            return
        }

        guard
            let startDateObj = Date.parseDate(startDate),
            let endDateObj = Date.parseDate(endDate)
        else {
            print("❌ Invalid date format: \(startDate) / \(endDate)")
            return
        }

        let requestDateFrom = startDateObj.toApiDateString() // "2025-09-01"
        var requestDateTo   = endDateObj.toApiDateString()   // "2025-09-03"
        let requestDateFromPeriod = MorningOrNightTextField.text?.lowercased() == "morning" ? "am" : "pm"
        let isHalfDay = halfDayButton.isSelected
        let isCustomHours = customHoursButton.isSelected
        let hourFrom = isCustomHours ? formatToAPITime(clockFrom.text) : nil
        let hourTo   = isCustomHours ? formatToAPITime(ClockTo.text)   : nil
        if endDateCalender.isHidden {
            requestDateTo = requestDateFrom
            print("hourTo when end date hidden: \(requestDateTo)")
        }
        viewModel.submitTimeOffRequest(
            token: token,
            leaveTypeId: leaveTypeId,
            action: "request_annual_leave",
            requestDateFrom: requestDateFrom,
            requestDateTo: requestDateTo,
            requestDateFromPeriod: requestDateFromPeriod,
            requestUnitHalf: isHalfDay,
            hourFrom: hourFrom ,
            hourTo: hourTo
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("✅ Request Success: \(response.result?.message ?? "Success")")
                    if response.result?.status == "success" {
                        self.showAlert(title: "Success", message: "Time off request submitted successfully.", completion: {
                            self.dismiss(animated: true)
                        })
                    } else {
                        self.showAlert(title: "Alert", message:  response.result?.message ?? "")
                    }
                case .failure(let error):
                    print("❌ Request Failed: \(error)")
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    @objc private func languageChanged() {
        setUpTexts()
        setupPickers()
    }
    
    func getDuration() {
        guard
            let token = UserDefaults.standard.string(forKey: "employeeToken"),
            let leaveTypeName = selectLeaveTypeTextField.text,
            let leaveTypeId = filteredLeaveTypes.first(where: { $0.name == leaveTypeName })?.id,
            let startDate = startDateCalender.text,
            let endDate = endDateCalender.text
        else {
            print("❌ Missing required fields")
            return
        }
        guard
            let startDateObj = Date.parseDate(startDate),
            let endDateObj = Date.parseDate(endDate)
        else {
            print("❌ Invalid date format: \(startDate) / \(endDate)")
            return
        }

        let requestDateFrom = startDateObj.toAPIDateString() // "09-07-2025"
        var requestDateTo   = endDateObj.toAPIDateString()   // "09-07-2025"
        let requestDateFromPeriod = MorningOrNightTextField.text?.lowercased() == "morning" ? "am" : "pm"
        let isHalfDay = halfDayButton.isSelected
        let isCustomHours = customHoursButton.isSelected
        let hourFrom = isCustomHours ? formatToAPITime(clockFrom.text) : nil
        var hourTo   = isCustomHours ? formatToAPITime(ClockTo.text)   : nil
        if endDateCalender.isHidden {
            requestDateTo = requestDateFrom
        }
        print("hourTo: \(requestDateTo)")
        leaveDurationVM.fetchLeaveDuration(
            token: token,
            leaveTypeId: leaveTypeId,
            requestDateFrom: requestDateFrom,
            requestDateTo: requestDateTo,
            requestDateFromPeriod: requestDateFromPeriod,
            requestUnitHalf: isHalfDay,
            requestHourFrom: hourFrom,
            requestHourTo: hourTo,
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

    func setUpAnnualMode() {
        clockStackView.isHidden = true
        startDateCalender.isHidden = false
        endDateCalender.isHidden = false
        selectLeaveTypeTextField.isHidden = false
        MorningOrNightTextField.isHidden = true
        customHoursButton.isHidden = true
    }
    
    func setUpHalfDayMode() {
        let normalImage = UIImage(systemName: "square")
        let selectedImage = UIImage(systemName: "checkmark.square.fill")
        halfDayButton.setImage(normalImage, for: .normal)
        halfDayButton.setImage(selectedImage, for: .selected)
        halfDayButton.backgroundColor = .clear
        startDateCalender.isHidden = false
        endDateCalender.isHidden = true
        selectLeaveTypeTextField.isHidden = false
        MorningOrNightTextField.isHidden = false
    }
    
    func setUpOtherMode() {
        startDateCalender.isHidden = false
        endDateCalender.isHidden = false
        selectLeaveTypeTextField.isHidden = false
        MorningOrNightTextField.isHidden = true
        customHoursButton.isHidden = false
        halfDayButton.isHidden = false
    }
    
   func setUpCustomHoursMode() {
       clockStackView.isHidden = false
       endDateCalender.isHidden = true
       let normalImage = UIImage(systemName: "square")
       let selectedImage = UIImage(systemName: "checkmark.square.fill")
       customHoursButton.setImage(normalImage, for: .normal)
       customHoursButton.setImage(selectedImage, for: .selected)
       customHoursButton.backgroundColor = .clear
    }
}

extension TimeOffRequestViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func setupPickers() {
        let lang = LanguageManager.shared.currentLanguage()
        print("🌍 Current language: \(lang)")
        
        let localeIdentifier = lang == "ar" ? "ar" : "en"
        let locale = Locale(identifier: localeIdentifier)
       
        setPickerLocale(picker: startDatePicker, textField: startDateCalender, locale: locale)
        setPickerLocale(picker: endDatePicker, textField: endDateCalender, locale: locale)
        setPickerLocale(picker: clockFromPicker, textField: clockFrom, locale: locale)
        setPickerLocale(picker: clockToPicker, textField: ClockTo, locale: locale)
        
        print("✅ Set all pickers to: \(localeIdentifier)")
        
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
    
        // ⏰ Setup time pickers
        clockFromPicker.datePickerMode = .time
        clockToPicker.datePickerMode = .time
        clockFromPicker.minuteInterval = 30   // ✅ only allow 30 min steps
        clockToPicker.minuteInterval = 30
        
        if #available(iOS 13.4, *) {
            startDatePicker.preferredDatePickerStyle = .wheels
            endDatePicker.preferredDatePickerStyle = .wheels
            clockFromPicker.preferredDatePickerStyle = .wheels
            clockToPicker.preferredDatePickerStyle = .wheels
        }

        startDateCalender.inputView = startDatePicker
        endDateCalender.inputView = endDatePicker
        startDatePicker.date = Date()
        endDatePicker.date = Date()
        startDateCalender.text = formatDate(Date())
        endDateCalender.text = formatDate(Date())
        startDateCalender.text = formatDate(startDatePicker.date)
        endDateCalender.text = formatDate(endDatePicker.date)
        
        // 🎛 Toolbar with Done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        toolbar.setItems([done], animated: true)
    
        selectLeaveTypeTextField.inputAccessoryView = toolbar
        MorningOrNightTextField.inputAccessoryView = toolbar
        startDateCalender.inputAccessoryView = toolbar
        endDateCalender.inputAccessoryView = toolbar
        clockFrom.inputView = clockFromPicker
        ClockTo.inputView = clockToPicker
        clockFrom.inputAccessoryView = toolbar
        ClockTo.inputAccessoryView = toolbar
    }

    private func setPickerLocale(picker: UIDatePicker, textField: UITextField, locale: Locale) {
        picker.locale = locale
        if let inputPicker = textField.inputView as? UIDatePicker {
            inputPicker.locale = locale
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
           let lang = LanguageManager.shared.currentLanguage()
           formatter.locale = Locale(identifier: lang == "ar" ? "ar" : "en")
           formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    @objc func doneTapped() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        if startDateCalender.isFirstResponder {
            startDateCalender.text = dateFormatter.string(from: startDatePicker.date)
        } else if endDateCalender.isFirstResponder {
            endDateCalender.text = dateFormatter.string(from: endDatePicker.date)
        } else if clockFrom.isFirstResponder {
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short // shows "11:30 AM"
            clockFrom.text = timeFormatter.string(from: clockFromPicker.date)
        } else if ClockTo.isFirstResponder {
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            ClockTo.text = timeFormatter.string(from: clockToPicker.date)
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
                setUpOtherMode()
            }
            else {
                setUpAnnualMode()
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
        clockLabel.text = NSLocalizedString("Clock", comment: "")
        saveButton.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
    }
}
