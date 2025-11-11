//
//  TimeOffViewController.swift
//  HR
//
//  Created by Esther Elzek on 10/08/2025.
//

import UIKit
import FSCalendar

enum LeaveStatePriority: Int {
    case refuse = 1
    case confirm = 2
    case validate = 3
    
    static func priority(for state: String) -> Int {
        switch state.lowercased() {
        case "validate": return Self.validate.rawValue
        case "confirm":  return Self.confirm.rawValue
        case "refuse":   return Self.refuse.rawValue
        default:          return 0
        }
    }
}

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
  //  var leaveDayRecords: [Date: DailyRecord] = [:]
    var leaveDayRecords: [Date: [DailyRecord]] = [:]

   // var leaveHourRecords: [Date: HourlyRecord] = [:]
    var leaveHourRecords: [Date: [HourlyRecord]] = [:]

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
        leaveTypesCollectionView.register(UINib(nibName: "TypesOfLeavesCollectionViewCell", bundle: nil),forCellWithReuseIdentifier: "TypesOfLeavesCollectionViewCell")
        statesTypesCollectionView.register(UINib(nibName: "TypesOfLeavesCollectionViewCell", bundle: nil),forCellWithReuseIdentifier: "TypesOfLeavesCollectionViewCell")
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
                        print("records: \(records)")
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

                            let colorHex = self?.leaveTypes.first(where: { $0.name == record.leaveType })?.color
                            let finalHex = (colorHex?.isEmpty == false) ? colorHex! : "#B7F73E"
                            let color = UIColor.fromHex(finalHex)
                            let days = self?.datesBetween(start: start, end: end) ?? []

                            for day in days {
                                // Append to array like we do for hourly
                                if var arr = self?.leaveDayRecords[day] {
                                    arr.append(record)
                                    arr[arr.count - 1].color = finalHex
                                    self?.leaveDayRecords[day] = arr
                                } else {
                                    var newArr: [DailyRecord] = [record]
                                    newArr[0].color = finalHex
                                    self?.leaveDayRecords[day] = newArr
                                }
                                self?.leaveDayColors[day] = color
                            }
                        }

                        for record in records.records.hourlyRecords {
                            guard let leaveDay = formatter.date(from: record.leaveDay) else { continue }

                            // 🎨 Find color for this leave type
                            let colorHex = self?.leaveTypes.first(where: { $0.name == record.leaveType })?.color
                            let finalHex = (colorHex?.isEmpty == false) ? colorHex! : "#B7F73E"
                            let color = UIColor.fromHex(finalHex)

                            // Append the record into the array for that day
                            if var arr = self?.leaveHourRecords[leaveDay] {
                                arr.append(record)
                                // update the color inside the appended value (structs are value types)
                                arr[arr.count - 1].color = finalHex
                                self?.leaveHourRecords[leaveDay] = arr
                                print("🔁 Appended hourly record for \(leaveDay) → now \(arr.count) records")
                            } else {
                                var newArr: [HourlyRecord] = [record]
                                newArr[0].color = finalHex
                                self?.leaveHourRecords[leaveDay] = newArr
                                print("➕ Created hourly records array for \(leaveDay)")
                            }

                            // Save color for calendar cell using the last record's color (last wins)
                            self?.leaveDayColors[leaveDay] = color
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
    
     func loadAllData(completion: @escaping () -> Void) {
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
        guard let allRecords = employeeTimeOffRecords else { return }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let targetDateString = dateFormatter.string(from: normalizedDate)
        let matchingDaily = allRecords.dailyRecords.filter {
            $0.startDate == targetDateString || $0.endDate == targetDateString
        }

        let matchingHourly = allRecords.hourlyRecords.filter {
            $0.leaveDay == targetDateString
        }
        let combinedRecords: [LeaveRecord] =
            matchingDaily.map { $0 as LeaveRecord } + matchingHourly.map { $0 as LeaveRecord }

        if !combinedRecords.isEmpty {
            goToResultOfRequest(for: normalizedDate, records: combinedRecords)

        } else {
            navigateToTimeOffRequest(selectedDate: date)
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

        if let records = leaveHourRecords[normalizedDate], let last = records.last {
            state = last.state
            color = last.color ?? ""
        }
        else if let records = leaveDayRecords[normalizedDate], let last = records.last {
            state = last.state
            color = last.color ?? ""
        }
        cell.backgroundColor = .clear
        if publicHolidays.contains(where: { Calendar.current.isDate($0, inSameDayAs: normalizedDate) }) {
            cell.backgroundColor = .lightGray.withAlphaComponent(0.1)
        }

        if !weekendDays.isEmpty {
            let weekday = Calendar.current.component(.weekday, from: normalizedDate)
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
        if let records = leaveHourRecords[normalizedDate], let last = records.last {
            state = last.state
        }
        else if let records = leaveDayRecords[normalizedDate], let last = records.last {
            state = last.state
        }
        switch state {
        case "validate":
            return .black
        case "confirm":
            return .label
        case "refuse":
            return .label
        default:
            return appearance.titleDefaultColor
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
    
    func navigateToTimeOffRequest(selectedDate: Date? = nil) {
        let timeOffRequestVC = TimeOffRequestViewController()
        timeOffRequestVC.filteredLeaveTypes = leaveTypes.filter { leave in
            (leave.requiresAllocation == "yes" && leave.remainingBalance != nil)
        }
        timeOffRequestVC.preselectedDate = selectedDate
        timeOffRequestVC.parentViewControllerRef = self // ✅ Pass real parent reference
        timeOffRequestVC.modalPresentationStyle = .overFullScreen
        timeOffRequestVC.modalTransitionStyle = .crossDissolve
        timeOffRequestVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        present(timeOffRequestVC, animated: true, completion: nil)
    }

    func goToResultOfRequest(for selectedDate: Date, records: [LeaveRecord]) {
        let resultVC = ResultOfRequestAlartViewController()
        resultVC.parentObject = self
        resultVC.selectedDate = selectedDate
        resultVC.filteredRecords = records
        resultVC.modalPresentationStyle = .overFullScreen
        resultVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        resultVC.modalTransitionStyle = .crossDissolve
        present(resultVC, animated: true)
    }


}
