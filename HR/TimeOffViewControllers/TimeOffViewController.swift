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
extension HourlyRecord: LeaveRecord {}

class TimeOffViewController: UIViewController {

    @IBOutlet weak var timeOffScreenTitle: UILabel!
    @IBOutlet weak var calender: FSCalendar!
    @IBOutlet weak var toApproveLabel: UILabel!
    @IBOutlet weak var firstAprroveLabel: UILabel!
    @IBOutlet weak var secondApproveLabel: UILabel!
    @IBOutlet weak var refusedLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loaderIndicator: UIActivityIndicatorView!
    
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
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setUpTexts()
//        loadHolidays()
//        loadTimeOffData()
//        setupBindings()
//        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
//        collectionView.register(nib, forCellWithReuseIdentifier: "CollectionViewCell")
//        NotificationCenter.default.addObserver(self,selector: #selector(languageChanged),name: NSNotification.Name("LanguageChanged"),object: nil)
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTexts()
        loaderIndicator.startAnimating()
        loadAllData { [weak self] in
            self?.loaderIndicator.stopAnimating()
            print("✅ All APIs finished")
        }
        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "CollectionViewCell")
        NotificationCenter.default.addObserver(self,selector: #selector(languageChanged),name: NSNotification.Name("LanguageChanged"),object: nil)
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func languageChanged() {
        setUpTexts()
    }

    private func loadHolidays(completion: @escaping () -> Void) {
        guard let token = UserDefaults.standard.employeeToken else { return completion() }
        viewModel.fetchHolidays(token: token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let offs = data.weekly_offs {
                        self?.weekendDays = offs.keys.compactMap { Int($0) }
                    }
                    if let holidays = data.public_holidays {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        self?.publicHolidays = holidays.compactMap { formatter.date(from: $0.start_date) }
                    }
                    self?.calender.reloadData()
                case .failure(let error):
                    print("❌ Holiday API Error:", error)
                }
                completion() // ✅ always call completion
            }
        }
    }

    private func loadTimeOffData(completion: @escaping () -> Void) {
        guard let token = UserDefaults.standard.employeeToken else { return completion() }
        viewModel.fetchTimeOff(token: token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let leaveTypes = response.result?.leaveTypes {
                        self?.leaveTypes = leaveTypes
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
                        
                        // ✅ Handle Daily Records
                        for record in records.records.dailyRecords {
                            guard
                                let start = formatter.date(from: record.startDate),
                                let end = formatter.date(from: record.endDate)
                            else { continue }
                            
                            let color = self?.color(for: record.state) ?? .clear
                            let days = self?.datesBetween(start: start, end: end) ?? []
                            
                            for day in days {
                                self?.leaveDayColors[day] = color
                                self?.leaveDayRecords[day] = record
                            }
                        }
                        
                        // ✅ Handle Hourly Records
                        for record in records.records.hourlyRecords {
                            guard
                                let start = formatter.date(from: record.startDate),
                                let end = formatter.date(from: record.endDate)
                            else { continue }
                            
                            let color = self?.color(for: record.state) ?? .blue
                            let days = self?.datesBetween(start: start, end: end) ?? []
                            
                            for day in days {
                                self?.leaveHourRecords[day] = record
                                if self?.leaveDayColors[day] == nil {
                                    self?.leaveDayColors[day] = color
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

        // Holidays
        group.enter()
        loadHolidays {
            group.leave()
        }

        // Time off data
        group.enter()
        loadTimeOffData {
            group.leave()
        }

        // Employee records
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

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        let weekday = apiWeekday(for: date)
        if weekendDays.contains(weekday) {
            return UIColor.lightGray.withAlphaComponent(0.3)
        }
        
        if publicHolidays.contains(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
            return UIColor.lightGray.withAlphaComponent(0.5)
        }
        
        if let color = leaveDayColors.keys.first(where: { Calendar.current.isDate($0, inSameDayAs: date) }).flatMap({ leaveDayColors[$0] }) {
                    return color
        }
        
        if selectedDates.contains(date) {
            return .clear
        }
        return nil
    }
}

extension TimeOffViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredLeaveTypes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }
        let leave = filteredLeaveTypes[indexPath.item]
        cell.configure(with: leave)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2, height: 200)
    }
}

extension TimeOffViewController {
    func setUpTexts() {
        calender.delegate = self
        calender.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        timeOffScreenTitle.text = NSLocalizedString("time_off_title", comment: "")
        toApproveLabel.text = NSLocalizedString("to_approve", comment: "")
        firstAprroveLabel.text = NSLocalizedString("second_approval", comment: "")
        secondApproveLabel.text = NSLocalizedString("approved", comment: "")
        refusedLabel.text = NSLocalizedString("refused", comment: "")

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
        calender.reloadData()
    }
    
    func navigateToTimeOffRequest() {
        let timeOffRequestVC = TimeOffRequestViewController()
        timeOffRequestVC.filteredLeaveTypes = leaveTypes.filter { leave in
                (leave.requiresAllocation == "yes" && leave.remainingBalance != nil)
            }
        print("timeOffRequestVC.filteredLeaveTypes: \(timeOffRequestVC.filteredLeaveTypes)")
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
