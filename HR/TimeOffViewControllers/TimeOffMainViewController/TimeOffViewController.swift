//
//  TimeOffViewController.swift
//  HR
//
//  Created by Esther Elzek on 10/08/2025.
//

import UIKit
import FSCalendar

protocol LeaveRecord {
    var leaveID: Int { get }
    var leaveType: String { get }
    var startDate: String { get }
    var endDate: String { get }
    var state: String { get }
}

extension DailyRecord: LeaveRecord {}
extension HourlyRecord: LeaveRecord {
    var startDate: String {
        // Combine leaveDay + requestHourFrom
        return "\(leaveDay) \(requestHourFrom):00"
    }
    
    var endDate: String {
        // Combine leaveDay + requestHourTo
        return "\(leaveDay) \(requestHourTo):00"
    }
}

class TimeOffViewController: UIViewController {

    @IBOutlet weak var timeOffScreenTitle: UILabel!
    @IBOutlet weak var calender: FSCalendar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loaderIndicator: UIActivityIndicatorView!
    @IBOutlet weak var leaveTypesCollectionView: UICollectionView!
    @IBOutlet weak var statesTypesCollectionView: UICollectionView!
    
    var selectedDates: [Date] = []
    let viewModel = TimeOffViewModel()
    let viewModelTimeOff = EmployeeTimeOffViewModel()
    var weekendDays: [Int] = []
    var publicHolidays: [Date] = []
    var leaveTypes: [LeaveType] = []
    var filteredLeaveTypes: [LeaveType] = []
    var leaveDayColors: [Date: UIColor] = [:]
    var employeeTimeOffRecords: EmployeeTimeOffRecords?
    var leaveDayRecords: [Date: DailyRecord] = [:]
    var leaveHourRecords: [Date: HourlyRecord] = [:]
    let stateTypes: [StateType] = [
        StateType(title: "Refused", key: "refuse"),
        StateType(title: "Confirmed", key: "confirm"),
        StateType(title: "Validated", key: "validate")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTexts()
        loaderIndicator.startAnimating()
        loadTimeOffData() {}
        loadAllData { [weak self] in
            self?.loaderIndicator.stopAnimating()
            print("✅ All APIs finished")
        }
        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "CollectionViewCell")
        NotificationCenter.default.addObserver(self,selector: #selector(languageChanged),name: NSNotification.Name("LanguageChanged"),object: nil)
        calender.register(TimeOffCalendarCell.self, forCellReuseIdentifier: "TimeOffCalendarCell")
        leaveTypesCollectionView.delegate = self
        leaveTypesCollectionView.dataSource = self
        statesTypesCollectionView.delegate = self
        statesTypesCollectionView.dataSource = self
        leaveTypesCollectionView.register(UINib(nibName: "TypesOfLeavesCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "TypesOfLeavesCollectionViewCell")
        statesTypesCollectionView.register(UINib(nibName: "TypesOfLeavesCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "TypesOfLeavesCollectionViewCell")
       
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func languageChanged() {
        setUpTexts()
    }

    private func loadHolidays(completion: @escaping () -> Void) {
        guard let token = UserDefaults.standard.employeeToken else {
            print("⚠️ No employee token found.")
            return completion()
        }

        print("📡 Fetching holidays and weekends from API...")

        viewModel.fetchHolidays(token: token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    print("✅ Holiday API Success: \(data)")

                    if let offs = data.weekly_offs {
                        self?.weekendDays = offs.keys.compactMap { Int($0) }
                        print("🗓 Weekend days (from API): \(self?.weekendDays ?? [])")
                    } else {
                        print("⚠️ No weekend days found in response.")
                    }

                    if let holidays = data.public_holidays {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"

                        self?.publicHolidays = holidays.compactMap { holiday in
                            let date = formatter.date(from: holiday.start_date)
                            if let d = date {
                                print("🎉 Parsed public holiday: \(holiday.start_date) → \(d)")
                            } else {
                                print("⚠️ Failed to parse holiday date: \(holiday.start_date)")
                            }
                            return date
                        }

                        print("📅 All parsed public holidays: \(self?.publicHolidays ?? [])")
                    } else {
                        print("⚠️ No public holidays found in response.")
                    }

                    self?.calender.reloadData()
                    print("🔄 Calendar reloaded after holidays update.")

                case .failure(let error):
                    print("❌ Holiday API Error: \(error.localizedDescription)")
                }

                completion() // ✅ Always call completion
            }
        }
    }


    private func loadTimeOffData(completion: @escaping () -> Void) {
        guard let token = UserDefaults.standard.employeeToken else { return completion() }
        viewModel.fetchTimeOff(token: token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("raw response: \(response)")
                    if let leaveTypes = response.result?.leaveTypes {
                        self?.leaveTypes = leaveTypes
                        self?.leaveTypesCollectionView.reloadData()
                        self?.statesTypesCollectionView.reloadData()
                        self?.filteredLeaveTypes = leaveTypes.filter { leave in
                            !(leave.requiresAllocation == "no")
                        }
                        self?.collectionView.reloadData()
                    }
                case .failure(let error):
                    print("❌ TimeOff API Error:", error)
                }
                completion()
            }
        }
    }

    private func setupBindings(completion: @escaping () -> Void) {
        loaderIndicator.startAnimating()
        if let token = UserDefaults.standard.string(forKey: "employeeToken") {
            viewModelTimeOff.fetchEmployeeTimeOffs(token: token) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let records):
                        
                        self?.employeeTimeOffRecords = records.records
                        self?.leaveDayColors.removeAll()
                        self?.leaveDayRecords.removeAll()
                        self?.leaveHourRecords.removeAll()
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        
                        for record in records.records.dailyRecords {
                            guard
                                let start = formatter.date(from: record.startDate),
                                let end = formatter.date(from: record.endDate)
                            else { continue }

                            // 🔍 Find the matching leave type by name
                            let  colorHex = self?.leaveTypes.first(where: { $0.name == record.leaveType })?.color
                            let finalHex = (colorHex?.isEmpty == false) ? colorHex! : "#B7F73E" // ✅ Default color if missing or empty
                            let color = UIColor.fromHex(finalHex)

                            let days = self?.datesBetween(start: start, end: end) ?? []
                            for day in days {
                                self?.leaveDayColors[day] = color
                                self?.leaveDayRecords[day] = record
                                self?.leaveDayRecords[day]?.color = finalHex
                            }
                        }

                        for record in records.records.hourlyRecords {
                            guard
                                let start = formatter.date(from: record.leaveDay),
                                let end = formatter.date(from: record.leaveDay)
                            else { continue }

                            // 🔍 Find the matching leave type by name
                            let colorHex = self?.leaveTypes.first(where: { $0.name == record.leaveType })?.color
                            let finalHex = (colorHex?.isEmpty == false) ? colorHex! : "#B7F73E" // ✅ Same default fallback
                            let color = UIColor.fromHex(finalHex)

                            let days = self?.datesBetween(start: start, end: end) ?? []
                            for day in days {
                                self?.leaveHourRecords[day] = record
                                if self?.leaveDayColors[day] == nil {
                                    self?.leaveDayColors[day] = color
                                    self?.leaveHourRecords[day]?.color = finalHex
                                }
                            }
                        }

                        self?.calender.reloadData()
                    case .failure(let error):
                        print("❌ Error: \(error)")
                    }
                    self?.loaderIndicator.stopAnimating()
                    self?.loaderIndicator.hidesWhenStopped = true
                    completion() // ✅ tell DispatchGroup we’re done
                }
            }
        } else {
            completion() // no token, finish immediately
        }
    }
    
    private func loadAllData(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        group.enter()
        loadHolidays {
            group.leave()
        }
        group.enter()
        loadTimeOffData {
            group.leave()
        }
        group.enter()
        setupBindings {
            group.leave()
        }
        group.notify(queue: .main) {
            completion()
        }
    }
}

extension TimeOffViewController: FSCalendarDelegate, FSCalendarDataSource {

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDates.append(date)
        let normalizedDate = Calendar.current.startOfDay(for: date)
        if let daily = leaveDayRecords[normalizedDate] {
            goToResultOfRequest(with: daily)
        } else if let hourly = leaveHourRecords[normalizedDate] {
            goToResultOfRequest(with: hourly) // overload or separate handler
        } else {
            navigateToTimeOffRequest()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                if traitCollection.userInterfaceStyle == .dark {
                    calender.appearance.titleDefaultColor = .white
                    calender.appearance.headerTitleColor = .white
                    calender.appearance.weekdayTextColor = .white
                } else {
                    calender.appearance.titleDefaultColor = .black
                    calender.appearance.headerTitleColor = .black
                    calender.appearance.weekdayTextColor = .black
            }
                calender.reloadData()
        }
    }
}

extension TimeOffViewController: FSCalendarDelegateAppearance {

    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "TimeOffCalendarCell", for: date, at: position) as! TimeOffCalendarCell
        let normalizedDate = Calendar.current.startOfDay(for: date)

        var state = ""
        var color = ""

        if let record = leaveDayRecords[normalizedDate] {
            state = record.state
            color = record.color ?? ""
        } else if let record = leaveHourRecords[normalizedDate] {
            state = record.state
            color = record.color ?? ""
        }

        // ✅ Default: clear background
        cell.backgroundColor = .clear

        // ✅ Public holidays
        if publicHolidays.contains(where: { Calendar.current.isDate($0, inSameDayAs: normalizedDate) }) {
            cell.backgroundColor = .lightGray.withAlphaComponent(0.1)
        }

        if !weekendDays.isEmpty {
            let weekday = Calendar.current.component(.weekday, from: normalizedDate)
            // Convert Apple's weekday (1–7, Sunday = 1) → API weekday (0–6, Monday = 0)
            let convertedIndex = (weekday + 5) % 7

            if weekendDays.contains(convertedIndex) {
                cell.backgroundColor = .lightGray.withAlphaComponent(0.1)
            }
        }


        cell.configure(for: state, color: color)
        return cell
    }

    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
            let normalizedDate = Calendar.current.startOfDay(for: date)
            var state = ""
            
            if let record = leaveDayRecords[normalizedDate] {
                state = record.state
            } else if let record = leaveHourRecords[normalizedDate] {
                state = record.state
            }
            switch state {
            case "validate":
                return .black
            case "confirm":
                return .label
            case "refuse":
                return .label
            default:
                return appearance.titleDefaultColor // fallback to calendar default
            }
        }
}

extension TimeOffViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return filteredLeaveTypes.count
        } else if collectionView == self.leaveTypesCollectionView {
            return leaveTypes.count
        } else {
            return stateTypes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.collectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "CollectionViewCell",
                for: indexPath
            ) as? CollectionViewCell else {
                return UICollectionViewCell()
            }
            let leave = filteredLeaveTypes[indexPath.item]
            cell.configure(with: leave)
            return cell
        }
        
        else if collectionView == self.leaveTypesCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "TypesOfLeavesCollectionViewCell",
                for: indexPath
            ) as? TypesOfLeavesCollectionViewCell else {
                return UICollectionViewCell()
            }

            let leaveType = leaveTypes[indexPath.item]
            cell.titleLabel.text = leaveType.name

            // ✅ Use default color if nil or empty
            let colorHex = (leaveType.color?.isEmpty == false) ? leaveType.color! : "4B644A"
            cell.coloredButton.backgroundColor = UIColor.fromHex(colorHex)

            return cell
        }

     
        else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "TypesOfLeavesCollectionViewCell",
                for: indexPath
            ) as? TypesOfLeavesCollectionViewCell else {
                return UICollectionViewCell()
            }
            let state = stateTypes[indexPath.item]
            cell.titleLabel.text = state.title
            cell.configureState(for: state.key) // your custom drawing
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == self.collectionView {
            return CGSize(width: collectionView.frame.width / 2, height: 200)
        } else {
            return CGSize(width: 140, height: 33)
        }
    }
}


extension TimeOffViewController {
    func setUpTexts() {
        calender.delegate = self
        calender.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        timeOffScreenTitle.text = NSLocalizedString("time_off_title", comment: "")
        if LanguageManager.shared.currentLanguage() == "ar" {
            calender.locale = Locale(identifier: "ar")
        } else {
            calender.locale = Locale(identifier: "en")
        }
        calender.semanticContentAttribute = .forceLeftToRight
        calender.calendarHeaderView.semanticContentAttribute = .forceLeftToRight
        calender.calendarWeekdayView.semanticContentAttribute = .forceLeftToRight
        calender.collectionView.semanticContentAttribute = .forceLeftToRight
        
        if traitCollection.userInterfaceStyle == .dark {
            calender.appearance.titleDefaultColor = .white
        } else {
            calender.appearance.titleDefaultColor = .black
        }
        
        for subview in calender.calendarHeaderView.subviews {
            subview.semanticContentAttribute = .forceLeftToRight
            if let label = subview as? UILabel {
                label.textAlignment = .center
            }
        }
        calender.appearance.headerTitleColor = UIColor.purplecolor
        calender.appearance.weekdayTextColor = UIColor.purplecolor
        calender.appearance.selectionColor = .clear
        calender.appearance.todayColor = .clear  // if you also don’t want today colored
        calender.reloadData()
    }
    
    func navigateToTimeOffRequest() {
        let timeOffRequestVC = TimeOffRequestViewController()
        timeOffRequestVC.filteredLeaveTypes = leaveTypes.filter { leave in
                (leave.requiresAllocation == "yes" && leave.remainingBalance != nil)
            }
        timeOffRequestVC.modalPresentationStyle = .overFullScreen
        timeOffRequestVC.modalTransitionStyle = .crossDissolve
        timeOffRequestVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        present(timeOffRequestVC, animated: true, completion: nil)
    }
    
    func goToResultOfRequest(with record: LeaveRecord) {
        let resultOfRequestVC = ResultOfRequestAlartViewController()
        resultOfRequestVC.modalPresentationStyle = .overFullScreen
        resultOfRequestVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        resultOfRequestVC.modalTransitionStyle = .crossDissolve
        resultOfRequestVC.fillTextFields(record: record) // <-- Make this accept LeaveRecord
        present(resultOfRequestVC, animated: true, completion: nil)
    }
}
