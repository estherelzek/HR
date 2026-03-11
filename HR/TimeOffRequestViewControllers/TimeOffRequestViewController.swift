//
//  TimeOffRequestViewController.swift
//  HR
//
//  Created by Esther Elzek on 26/08/2025.
//

import UIKit
enum LeaveUnit {
    case day
    case halfDay
    case hour
    case hourOnly
}
private enum WarningState {
    case hidden
    case casual
    case exceed
}
class TimeOffRequestViewController: UIViewController , UITextFieldDelegate {
    
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
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var contentView: InspectableView!
    @IBOutlet var ouSideView: UIView!
    @IBOutlet weak var saveButtonTapped: InspectableButton!
    @IBOutlet weak var clockFrom: UITextField!
    @IBOutlet weak var ClockTo: UITextField!
    @IBOutlet weak var clockLabel: UILabel!
    @IBOutlet weak var clockStackView: UIStackView!
    @IBOutlet weak var saveButton: InspectableButton!
    @IBOutlet weak var dynamicStackView: UIStackView!
    @IBOutlet weak var WarningLabel: Inspectablelabel!
    @IBOutlet weak var warningContainer: UIView!

    @IBOutlet weak var scrollView: UIScrollView!
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
    var preselectedDate: Date?
    weak var parentViewControllerRef: TimeOffViewController?
    let animationDuration = 0.08 // super fast
    private var currentWarningState: WarningState = .hidden
    private var warningWorkItem: DispatchWorkItem?
    private let loader = UIActivityIndicatorView(style: .large)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        warningContainer.isHidden = true
          warningContainer.alpha = 0  // ✅ correct place
     
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOutsideTap(_:)))
        tapGesture.cancelsTouchesInView = false
        ouSideView.addGestureRecognizer(tapGesture)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageChanged),
            name: NSNotification.Name("LanguageChanged"),
            object: nil
        )
        selectLeaveTypeTextField.delegate = self
        setUpTexts()
        setupPickers()
        initialState()
        setupLoader()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
          NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        addDescriptionTextField.returnKeyType = .done
        addDescriptionTextField.delegate = self
      }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let lang = LanguageManager.shared.currentLanguage()
        setupPickers()
        if let date = preselectedDate {
            startDatePicker.date = date
            endDatePicker.date = date
            startDateCalender.text = formatDate(date)
            endDateCalender.text = formatDate(date)
        }
    }
    
    private func setupLoader() {
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.color = .systemGray   // 🔴 red spinner
        loader.hidesWhenStopped = true
        loader.alpha = 0
        
        view.addSubview(loader)
        
        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func initialState() {
        dynamicStackView.isHidden = false

          dynamicStackView.arrangedSubviews.forEach {
              $0.isHidden = true
          }

        // Reset buttons
        halfDayButton.isSelected = false
        customHoursButton.isSelected = false

        // Reset fields
        MorningOrNightTextField.text = nil
        clockFrom.text = nil
        ClockTo.text = nil
    }
    
    func showDynamicContent() {
        dynamicStackView.arrangedSubviews.forEach {
            $0.isHidden = false
        }
    }

    private func showSavingLoader() {
        view.isUserInteractionEnabled = false
        
        loader.startAnimating()
        
        UIView.animate(withDuration: 0.2) {
            self.loader.alpha = 1
        }
    }

    private func hideSavingLoader() {
        view.isUserInteractionEnabled = true
        
        UIView.animate(withDuration: 0.2, animations: {
            self.loader.alpha = 0
        }) { _ in
            self.loader.stopAnimating()
        }
    }
    
    func applyLeaveUnit(_ unit: LeaveUnit) {
        showDynamicContent()

        // reset visibility
        startDateCalender.isHidden = true
        endDateCalender.isHidden = true
        MorningOrNightTextField.isHidden = true
        halfDayButton.isHidden = true
        customHoursButton.isHidden = true
        clockStackView.isHidden = true

        switch unit {
        case .day:
            startDateCalender.isHidden = false
            endDateCalender.isHidden = false
        case .halfDay:
            startDateCalender.isHidden = false
            endDateCalender.isHidden = false
            halfDayButton.isHidden = false
        case .hour:
            startDateCalender.isHidden = false
            halfDayButton.isHidden = false
            customHoursButton.isHidden = false
        case .hourOnly:
            startDateCalender.isHidden = false
            clockStackView.isHidden = false
        }
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
            getDuration()
        } else {
            UnCLickHalfButton()
            getDuration()
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
            if halfDayButton .isHidden {
                UnCLickHalfButton(hideHalfButton: true)
            }else  {
                UnCLickHalfButton(hideHalfButton: false)
            }
        }
    }
    
    @objc private func handleOutsideTap(_ gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: contentView)
        if !contentView.bounds.contains(touchPoint) {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {

        showSavingLoader()

        guard
            let token = UserDefaults.standard.string(forKey: "employeeToken"),
            let leaveTypeName = selectLeaveTypeTextField.text,
            let leaveTypeId = filteredLeaveTypes.first(where: { $0.name == leaveTypeName })?.id,
            let startDate = startDateCalender.text,
            let endDate = endDateCalender.text
        else {
            hideSavingLoader()
            return
        }

        guard
            let startDateObj = Date.parseDate(startDate),
            let endDateObj = Date.parseDate(endDate)
        else {
            hideSavingLoader()
            return
        }

        let durationDateFrom = startDateObj.toDurationAPIDateString()
        var durationDateTo   = endDateObj.toDurationAPIDateString()

        if endDateCalender.isHidden {
            durationDateTo = durationDateFrom
        }

        let requestDateFromPeriod =
            MorningOrNightTextField.text?.lowercased() == "morning" ? "am" : "pm"

        let isHalfDay      = halfDayButton.isSelected
        let isCustomHours  = customHoursButton.isSelected

        let hourFrom = isCustomHours ? formatToAPITime(clockFrom.text) : nil
        let hourTo   = isCustomHours ? formatToAPITime(ClockTo.text)   : nil

        // STEP 1: Call Duration API First
        leaveDurationVM.fetchLeaveDuration(
            token: token,
            leaveTypeId: leaveTypeId,
            requestDateFrom: durationDateFrom,
            requestDateTo: durationDateTo,
            requestDateFromPeriod: requestDateFromPeriod,
            requestUnitHalf: isHalfDay,
            requestHourFrom: hourFrom,
            requestHourTo: hourTo,
            requestUnitHours: isCustomHours
        ) { [weak self] result in

            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {

                case .success(let result):

                    // ✅ Check business error first (HTTP 200 but status = "error")
                    if result.status == "error" {
                        self.hideSavingLoader()

                        switch result.errorCode ?? "" {
                        case "MISSING_HOURS", "MISSING_HOUR":
                            self.showAlert(
                                title: NSLocalizedString("alert_warning_title", comment: ""),
                                message: NSLocalizedString("hourly_leave_error", comment: "")
                            )
                        default:
                            let message = result.message?.isEmpty == false
                                ? result.message!
                                : NSLocalizedString("this_leave_time_is_not_eligible", comment: "")
                            self.showAlert(
                                title: NSLocalizedString("alert_warning_title", comment: ""),
                                message: message
                            )
                        }
                        return
                    }

                    // ✅ No error — read duration from nested data
                    let hours = result.data?.hours ?? 0
                    let days  = result.data?.days  ?? 0

                    if hours == 0 && days == 0 {
                        self.hideSavingLoader()
                        self.showAlert(
                            title: NSLocalizedString("alert_warning_title", comment: ""),
                            message: NSLocalizedString("this_leave_time_is_not_eligible", comment: "")
                        )
                        return
                    }

                    let requestDateFrom = startDateObj.toRequestAPIDateString()
                    let requestDateTo   = endDateObj.toRequestAPIDateString()
                    print("requestDateFrom: \(requestDateFrom) ,, requestDateTo: \(requestDateTo)")

                    self.submitFinalRequest(
                        token: token,
                        leaveTypeId: leaveTypeId,
                        requestDateFrom: requestDateFrom,
                        requestDateTo: requestDateTo,
                        requestDateFromPeriod: requestDateFromPeriod,
                        isHalfDay: isHalfDay,
                        hourFrom: hourFrom ?? "",
                        hourTo: hourTo ?? ""
                    )

                case .failure:
                    self.hideSavingLoader()
                    self.showAlert(
                        title: NSLocalizedString("error", comment: ""),
                        message: NSLocalizedString("weak_network_message", comment: "")
                    )
                }
            }
        }
    }
    private func submitFinalRequest(
        token: String,
        leaveTypeId: Int,
        requestDateFrom: String,
        requestDateTo: String,
        requestDateFromPeriod: String,
        isHalfDay: Bool,
        hourFrom: String,
        hourTo: String
    ) {
        viewModel.submitTimeOffRequest(
            token: token,
            leaveTypeId: leaveTypeId,
            action: "request_annual_leave",
            requestDateFrom: requestDateFrom,
            requestDateTo: requestDateTo,
            requestDateFromPeriod: requestDateFromPeriod,
            requestUnitHalf: isHalfDay,
            hourFrom: hourFrom,
            hourTo: hourTo
        ) { [weak self] result in

            DispatchQueue.main.async {
                guard let self = self else { return }
                self.hideSavingLoader()

                switch result {

                case .success(let response):

                    if response.result?.status == "success" {
                        // ✅ Happy path — dismiss and refresh
                        self.dismiss(animated: true) {
                            self.parentViewControllerRef?.loadAllData(completion: {})
                        }

                    } else {
                        // ✅ Check the specific error code from backend
                        let errorCode = response.result?.errorCode ?? ""

                        switch errorCode {

                        case "MISSING_HOUR", "MISSING_HOURS":
                            self.showAlert(
                                title: NSLocalizedString("alert_warning_title", comment: ""),
                                message: NSLocalizedString("hourly_leave_error", comment: "")
                            )

                        default:
                            // ⚠️ Any other business error — show the message from backend
                            let message = response.result?.message?.isEmpty == false
                                ? response.result!.message!
                                : NSLocalizedString("hourly_leave_error", comment: "")
                            self.showAlert(
                                title: NSLocalizedString("alert_warning_title", comment: ""),
                                message: message
                            )
                        }
                    }

                case .failure:
                    self.showAlert(
                        title: NSLocalizedString("error", comment: ""),
                        message: NSLocalizedString("weak_network_message", comment: "")
                    )
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
            print("❌ Invalid date format")
            return
        }

        let durationDateFrom = startDateObj.toDurationAPIDateString()
        var durationDateTo   = endDateObj.toDurationAPIDateString()


        if endDateCalender.isHidden {
            durationDateTo = durationDateFrom
        }

        let requestDateFromPeriod =
            MorningOrNightTextField.text?.lowercased() == "morning" ? "am" : "pm"

        let isHalfDay = halfDayButton.isSelected
        let isCustomHours = customHoursButton.isSelected

        let hourFrom = isCustomHours ? formatToAPITime(clockFrom.text) : nil
        let hourTo   = isCustomHours ? formatToAPITime(ClockTo.text)   : nil

        leaveDurationVM.fetchLeaveDuration(
            token: token,
            leaveTypeId: leaveTypeId,
            requestDateFrom: durationDateFrom,
            requestDateTo: durationDateTo,
            requestDateFromPeriod: requestDateFromPeriod,
            requestUnitHalf: isHalfDay,
            requestHourFrom: hourFrom,
            requestHourTo: hourTo,
            requestUnitHours: isCustomHours
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let result):
                    // ✅ Handle business error first
                    if result.status == "error" {
                        self?.updateWarning(state: .hidden, text: nil, color: nil)
                        return
                    }

                    let data = result.data  // ✅ unwrap once here, then use data.days / data.hours normally

                    self?.durationCountLabel.text =
                        "\(data?.days ?? 0) days (\(data?.hours ?? 0) hrs)"

                    self?.warningWorkItem?.cancel()

                    let workItem = DispatchWorkItem { [weak self] in
                        guard let self = self else { return }

                        if data?.checkCasualLeave == true {
                            self.updateWarning(
                                state: .casual,
                                text: """
                                This is a Casual Leave.
                                You have \(data?.remainingCasualDays ?? 0) days remaining.
                                """,
                                color: .systemGreen
                            )
                        } else if data?.casualLeaveWarning == true {
                            self.updateWarning(
                                state: .casual,
                                text: """
                                This leave will exceed your annual casual leave limit.
                                You have \(data?.remainingCasualDays ?? 0) days remaining.
                                """,
                                color: .systemYellow
                            )
                        } else {
                            self.updateWarning(state: .hidden, text: nil, color: nil)
                        }
                    }

                    self?.warningWorkItem = workItem
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: workItem)

                case .failure:
                    self?.updateWarning(state: .hidden, text: nil, color: nil)
                }
            }

            
        }
    }


    func UnCLickHalfButton(hideHalfButton: Bool = false) {
        clockStackView.isHidden = true
        startDateCalender.isHidden = false
        endDateCalender.isHidden = false
        selectLeaveTypeTextField.isHidden = false
        MorningOrNightTextField.isHidden = true
        halfDayButton.isHidden = hideHalfButton
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
        clockStackView.isHidden = true
    }
    
    func launchMode() {
        clockStackView.isHidden = true
        startDateCalender.isHidden = false
        endDateCalender.isHidden = false
        selectLeaveTypeTextField.isHidden = false
        MorningOrNightTextField.isHidden = true
        customHoursButton.isHidden = true
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
    
    func handleHalfDayMode() {
        // Day To & from
        //half button
        clockStackView.isHidden = true
        startDateCalender.isHidden = false
        endDateCalender.isHidden = false
        selectLeaveTypeTextField.isHidden = false
        MorningOrNightTextField.isHidden = true
        customHoursButton.isHidden = true
        halfDayButton.isHidden = false
    }
    
    func handleDayMode () {
        // what i need to show when i select type its unit day
        // show start & end Date
        clockStackView.isHidden = true
        startDateCalender.isHidden = false
        endDateCalender.isHidden = false
        selectLeaveTypeTextField.isHidden = false
        MorningOrNightTextField.isHidden = true
        customHoursButton.isHidden = true
        halfDayButton.isHidden = true
    }
    func handleHoursMode() {
        // what i need to show when i select type its unit hours
        // half day
        // show Custom hour button
        // start date calender
        halfDayButton.isHidden = false
        customHoursButton.isHidden = false
        startDateCalender.isHidden = false
        selectLeaveTypeTextField.isHidden = false
        
        clockStackView.isHidden = true
        endDateCalender.isHidden = true
        MorningOrNightTextField.isHidden = true
    }
    
    func handleHoursOnlyMode() {
        // start date calender
        //from & to stack of clock view
        clockStackView.isHidden = false
        startDateCalender.isHidden = false
        selectLeaveTypeTextField.isHidden = false
        
        endDateCalender.isHidden = true
        MorningOrNightTextField.isHidden = true
        halfDayButton.isHidden = true
        customHoursButton.isHidden = true
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
        leaveTypePicker.delegate = self
        leaveTypePicker.dataSource = self
        selectLeaveTypeTextField.inputView = leaveTypePicker
        morningNightPicker.delegate = self
        morningNightPicker.dataSource = self
        if !filteredLeaveTypes.isEmpty {
            leaveTypePicker.selectRow(0, inComponent: 0, animated: false)
            selectLeaveTypeTextField.text = filteredLeaveTypes[0].name
            
            // Apply correct UI mode automatically
            let type = filteredLeaveTypes[0]
            handleUnitSelection(for: type)
            
        }
        MorningOrNightTextField.inputView = morningNightPicker
        morningNightPicker.selectRow(0, inComponent: 0, animated: false)
        MorningOrNightTextField.text = pickerView(morningNightPicker, titleForRow: 0, forComponent: 0)
        startDatePicker.datePickerMode = .date
        endDatePicker.datePickerMode = .date
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

    private func handleUnitSelection(for type: LeaveType) {

        updateWarning(state: .hidden, text: nil, color: nil)

        switch type.requestUnit {
        case "day":
            applyLeaveUnit(.day)
        case "half_day":
            applyLeaveUnit(.halfDay)
        case "hour":
            applyLeaveUnit(.hour)
        case "hour_only":
            applyLeaveUnit(.hourOnly)
        default:
            break
        }

        getDuration()
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
            let type = filteredLeaveTypes[row]
            selectLeaveTypeTextField.text = type.name
            handleUnitSelection(for: type)
            return filteredLeaveTypes[row].name
        } else {
            return morningNightOptions[row]
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        if pickerView == leaveTypePicker {
            let type = filteredLeaveTypes[row]
            selectLeaveTypeTextField.text = type.name

            switch type.requestUnit {
            case "day":
                applyLeaveUnit(.day)
                // قبل أي عملية getDuration()
                updateWarning(state: .hidden, text: nil, color: nil)

              //  getDuration()
            case "half_day":
                applyLeaveUnit(.halfDay)
                // قبل أي عملية getDuration()
                updateWarning(state: .hidden, text: nil, color: nil)

               // getDuration()
            case "hour":
                applyLeaveUnit(.hour)
                // قبل أي عملية getDuration()
                updateWarning(state: .hidden, text: nil, color: nil)

                //getDuration()
            case "hour_only":
                applyLeaveUnit(.hourOnly)
                // قبل أي عملية getDuration()
                updateWarning(state: .hidden, text: nil, color: nil)

               // getDuration()
            default:
                break
            }
        } else {
            MorningOrNightTextField.text = morningNightOptions[row]
        }

        doneTapped()
        getDuration()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == selectLeaveTypeTextField,
           textField.text?.isEmpty ?? true,
           !filteredLeaveTypes.isEmpty {

            leaveTypePicker.selectRow(0, inComponent: 0, animated: false)
            selectLeaveTypeTextField.text = filteredLeaveTypes[0].name
            handleUnitSelection(for: filteredLeaveTypes[0])
        }
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
        descriptionLabel.text = NSLocalizedString("TimeOffRequest_Description", comment: "")
    }
    
    private func updateWarning(state: WarningState, text: String?, color: UIColor?) {
        print("🔔 updateWarning called → newState: \(state), currentState: \(currentWarningState)")
//        guard state != currentWarningState else {
//            print("⚠️ Same state, skipping animation")
//            return
//        }
        currentWarningState = state

        WarningLabel.text = text
        WarningLabel.backgroundColor = color

        switch state {
           case .hidden:
            print("hidden")
               // Hide warning completely so stack collapses
               UIView.animate(withDuration: 0.15, animations: {
                   self.warningContainer.alpha = 0
               }) { _ in
                   self.warningContainer.isHidden = true
                   self.dynamicStackView.layoutIfNeeded()
               }

           case .casual, .exceed:
            print("exceed")
               warningContainer.isHidden = false
               warningContainer.alpha = 0 // start invisible
               UIView.animate(withDuration: 0.15) {
                   self.warningContainer.alpha = 1
                   self.dynamicStackView.layoutIfNeeded()
               }
           }
    }
}

extension TimeOffRequestViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // dismiss keyboard
        return true
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let keyboardHeight = keyboardFrame.height
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets

        // Optional: scroll to active field
        if let activeField = view.currentFirstResponder() as? UIView {
            scrollView.scrollRectToVisible(activeField.frame, animated: true)
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
}
