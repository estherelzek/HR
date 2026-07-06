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
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("no_leave_available_message", comment: "")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .gray
        label.isHidden = true
        return label
    }()
    
    let stateTypes: [StateType] = [
        StateType(title: "Refused", key: "refuse"),
        StateType(title: "Confirmed", key: "confirm"),
        StateType(title: "Validated", key: "validate")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // In viewDidLoad, before loadAllData:
        calender.locale = Locale(identifier:
            LanguageManager.shared.currentLanguage() == "ar" ? "ar" : "en_US"
        )
        setUpTexts()
        
        // ✅ Configure loader before starting
        setupLoader()
        loaderIndicator.startAnimating()
      
        // ✅ Create a Task to run async code from non-async context
        // Task automatically runs on the main actor since this is a UIViewController
        Task {
            do {
                try await loadAllData()  // ✅ Simply await - no completion handler needed!
                print("✅ All APIs finished")
            } catch {
                print("❌ Error loading data: \(error)")
                if let apiError = error as? APIError {
                    showAPIError(apiError)
                }
            }
            // ✅ Stop and hide loader when done
            loaderIndicator.stopAnimating()
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
        view.addSubview(emptyStateLabel)
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.isHidden = false
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor, constant: 16),
            emptyStateLabel.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Loader Setup
    private func setupLoader() {
        // ✅ Ensure loader hides automatically when stopped
        loaderIndicator.hidesWhenStopped = true
        
        // ✅ Bring loader to front so it's visible above other views
        view.bringSubviewToFront(loaderIndicator)
        
        // ✅ Set style for better visibility
        if #available(iOS 13.0, *) {
            loaderIndicator.style = .medium
        } else {
            loaderIndicator.style = .medium
        }
        
        // ✅ Set color based on dark/light mode
        if traitCollection.userInterfaceStyle == .dark {
            loaderIndicator.color = .white
        } else {
            loaderIndicator.color = .gray
        }
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func languageChanged() {
        setUpTexts()
    }

    // MARK: - Async/Await version
    @MainActor
    private func loadHolidays() async throws {
        guard let token = UserDefaults.standard.employeeToken else {
            print("⚠️ No employee token found.")
            return
        }
        
        print("📡 Fetching holidays and weekends from API...")
        
        // ✅ Simply await the result - no completion handlers!
        let data = try await viewModel.fetchHolidays(token: token)
        
        print("✅ Holiday API Success: \(data)")
        
        if let offs = data.weekly_offs {
            weekendDays = offs.keys.compactMap { Int($0) }
            print("🗓 Weekend days (from API): \(weekendDays)")
        } else {
            print("⚠️ No weekend days found in response.")
        }
        
        if let holidays = data.public_holidays {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            publicHolidays = holidays.compactMap { holiday in
                let date = formatter.date(from: holiday.start_date)
                if date == nil {
                    print("⚠️ Failed to parse holiday date: \(holiday.start_date)")
                }
                return date
            }
            
            print("📅 All parsed public holidays: \(publicHolidays)")
        } else {
            print("⚠️ No public holidays found in response.")
        }
        
        calender.reloadData()
        print("🔄 Calendar reloaded after holidays update.")
    }

    @MainActor
    private func loadTimeOffData() async throws {
        guard let token = UserDefaults.standard.employeeToken else { return }
        
        // ✅ Simply await the result
        let response = try await viewModel.fetchTimeOff(token: token)
        
        print("raw response: \(response)")
        
        if let leaveTypes = response.result?.leaveTypes {
            self.leaveTypes = leaveTypes
            leaveTypesCollectionView.reloadData()
            statesTypesCollectionView.reloadData()
            
            filteredLeaveTypes = leaveTypes.filter { leave in
                !(leave.requiresAllocation == "no")
            }
            
            print("leaveTypes.count: \(leaveTypes.count)")
            collectionView.reloadData()
            updateEmptyState()
        }
    }
    
    func refreshAfterCancellation() {
        loaderIndicator.startAnimating()  // ✅ Show loader during refresh
        
        Task {
            await setupBindings()
            calender.reloadData()
            loaderIndicator.stopAnimating()  // ✅ Hide loader when done
        }
    }
    
    private func updateEmptyState() {
        let isEmpty = filteredLeaveTypes.isEmpty
        
        collectionView.isHidden = isEmpty
        emptyStateLabel.isHidden = !isEmpty
    }
    
    @MainActor
    private func setupBindings() async {
        guard let token = UserDefaults.standard.string(forKey: "employeeToken") else {
            return
        }
        
        do {
            // ✅ Await the API call
            let result = try await viewModelTimeOff.fetchEmployeeTimeOffs(token: token)
            
            print("records: \(result)")
            employeeTimeOffRecords = result.records
            leaveDayColors.removeAll()
            leaveDayRecords.removeAll()
            leaveHourRecords.removeAll()
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            // Process daily records
            for record in result.records.dailyRecords {
                guard
                    let start = formatter.date(from: record.startDate),
                    let end = formatter.date(from: record.endDate)
                else { continue }
                
                let colorHex = leaveTypes.first(where: { $0.name == record.leaveType })?.color
                let finalHex = (colorHex?.isEmpty == false) ? colorHex! : "#B7F73E"
                let color = UIColor.fromHex(finalHex)
                let days = datesBetween(start: start, end: end)
                
                for day in days {
                    if var arr = leaveDayRecords[day] {
                        arr.append(record)
                        arr[arr.count - 1].color = finalHex
                        leaveDayRecords[day] = arr
                    } else {
                        var newArr: [DailyRecord] = [record]
                        newArr[0].color = finalHex
                        leaveDayRecords[day] = newArr
                    }
                    leaveDayColors[day] = color
                }
            }
            
            // Process hourly records
            for record in result.records.hourlyRecords {
                guard let leaveDay = formatter.date(from: record.leaveDay) else { continue }
                
                let colorHex = leaveTypes.first(where: { $0.name == record.leaveType })?.color
                let finalHex = (colorHex?.isEmpty == false) ? colorHex! : "#B7F73E"
                let color = UIColor.fromHex(finalHex)
                
                if var arr = leaveHourRecords[leaveDay] {
                    arr.append(record)
                    arr[arr.count - 1].color = finalHex
                    leaveHourRecords[leaveDay] = arr
                    print("🔁 Appended hourly record for \(leaveDay) → now \(arr.count) records")
                } else {
                    var newArr: [HourlyRecord] = [record]
                    newArr[0].color = finalHex
                    leaveHourRecords[leaveDay] = newArr
                }
                
                leaveDayColors[leaveDay] = color
            }
            
            calender.reloadData()
            
        } catch {
            print("❌ Error fetching employee time offs: \(error)")
            if let apiError = error as? APIError {
                showAPIError(apiError)
            }
        }
    }
    
    // MARK: - Main data loading function with async/await
    /// Loads all data concurrently using async/await
    /// This demonstrates parallel API calls using async let
    @MainActor
    func loadAllData() async throws {
        print("🚀 Starting to load all data using async/await...")
        
        // ✅ Option 1: Run APIs in parallel using async let
        async let holidaysTask: Void = loadHolidays()
        async let timeOffTask: Void = loadTimeOffData()
        
        // Wait for both to complete (they run in parallel!)
        try await holidaysTask
        try await timeOffTask
        
        // ✅ Now that leaveTypes are loaded, fetch employee time offs
        await setupBindings()
        updateEmptyState()
        
        print("✅ All data loaded successfully!")
    }
}

extension TimeOffViewController: FSCalendarDelegate,
                                 FSCalendarDataSource,
                                 FSCalendarDelegateAppearance {

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDates.append(date)
        let normalizedDate = Calendar.current.startOfDay(for: date)
        guard let allRecords = employeeTimeOffRecords else { return }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let targetDateString = dateFormatter.string(from: normalizedDate)
        let matchingDaily = allRecords.dailyRecords.filter {
            ($0.startDate == targetDateString || $0.endDate == targetDateString) && $0.state.lowercased() != "cancel"
        }

        let matchingHourly = allRecords.hourlyRecords.filter {
            $0.leaveDay == targetDateString && $0.state.lowercased() != "cancel"
        }
        let combinedRecords: [LeaveRecord] =
            matchingDaily.map { $0 as LeaveRecord } + matchingHourly.map { $0 as LeaveRecord }

        if !combinedRecords.isEmpty  {
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

extension TimeOffViewController   {

    // MARK: - cellFor (in the FSCalendar extension)
    func calendar(_ calendar: FSCalendar,
                  cellFor date: Date,
                  at position: FSCalendarMonthPosition) -> FSCalendarCell {

        let cell = calendar.dequeueReusableCell(
            withIdentifier: "TimeOffCalendarCell",
            for: date,
            at: position
        ) as! TimeOffCalendarCell

        let normalizedDate = Calendar.current.startOfDay(for: date)

        // MARK: - Determine leave state and color
        var state = ""
        var color = ""

        if let records = leaveHourRecords[normalizedDate],
           let best = records.max(by: { LeaveStatePriority.priority(for: $0.state) < LeaveStatePriority.priority(for: $1.state) }) {
            state = best.state
            color = best.color ?? ""
        } else if let records = leaveDayRecords[normalizedDate],
                  let best = records.max(by: { LeaveStatePriority.priority(for: $0.state) < LeaveStatePriority.priority(for: $1.state) }) {
            state = best.state
            color = best.color ?? ""
        }

        // MARK: - Reset background
        cell.backgroundColor = .clear

        // MARK: - Public holiday / weekend coloring
        if publicHolidays.contains(where: { Calendar.current.isDate($0, inSameDayAs: normalizedDate) }) {
            cell.backgroundColor = .lightGray.withAlphaComponent(0.1)
        } else if !weekendDays.isEmpty {
            let weekday = Calendar.current.component(.weekday, from: normalizedDate)
            let convertedIndex = (weekday + 5) % 7
            if weekendDays.contains(convertedIndex) {
                cell.backgroundColor = .lightGray.withAlphaComponent(0.1)
            }
        }

        // ✅ Check if this date is today
        let isToday = Calendar.current.isDateInToday(date)

        // MARK: - Configure leave state visuals + today indicator
        cell.configure(for: state, color: color, isToday: isToday)

        return cell
    }

    // ✅ DELETE titleFor entirely — returning nil or any value here
    // overrides the locale-based rendering and causes English digits
    // func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? { }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        // Keep this — it still works on the real titleLabel
        let normalizedDate = Calendar.current.startOfDay(for: date)
        var state = ""
        if let records = leaveHourRecords[normalizedDate],
           let best = records.max(by: { LeaveStatePriority.priority(for: $0.state) < LeaveStatePriority.priority(for: $1.state) }) {
            state = best.state
        } else if let records = leaveDayRecords[normalizedDate],
                  let best = records.max(by: { LeaveStatePriority.priority(for: $0.state) < LeaveStatePriority.priority(for: $1.state) }) {
            state = best.state
        }
        switch state.lowercased() {
        case "validate": return .black
        case "confirm":  return .label
        case "refuse":   return .label
        default:         return appearance.titleDefaultColor
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
            print("leaveType.color?: \(leaveType.color)")
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
            calender.semanticContentAttribute = .forceRightToLeft
            calender.calendarHeaderView.semanticContentAttribute = .forceRightToLeft
            calender.calendarWeekdayView.semanticContentAttribute = .forceRightToLeft
            calender.collectionView.semanticContentAttribute = .forceRightToLeft
        } else {
            calender.locale = Locale(identifier: "en_US")
            calender.semanticContentAttribute = .forceLeftToRight
            calender.calendarHeaderView.semanticContentAttribute = .forceLeftToRight
            calender.calendarWeekdayView.semanticContentAttribute = .forceLeftToRight
            calender.collectionView.semanticContentAttribute = .forceLeftToRight
        }
        
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
            (leave.requiresAllocation == "yes" && leave.remainingBalance != nil) || leave.requiresAllocation == "no"
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
extension TimeOffViewController {
    // In your FSCalendar extension in TimeOffViewController
    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
        guard LanguageManager.shared.currentLanguage() == "ar" else {
            return nil // let FSCalendar render English normally
        }
        let day = Calendar.current.component(.day, from: date)
        return convertToArabicNumber(day)
    }
 
    private func convertToArabicNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ar_EG") // ← change to ar_EG for Eastern Arabic ١٢٣
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}
