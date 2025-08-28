//
//  TimeOffViewController.swift
//  HR
//
//  Created by Esther Elzek on 10/08/2025.
//

import UIKit
import FSCalendar

class TimeOffViewController: UIViewController {

    @IBOutlet weak var timeOffScreenTitle: UILabel!
    @IBOutlet weak var calender: FSCalendar!
    @IBOutlet weak var toApproveLabel: UILabel!
    @IBOutlet weak var firstAprroveLabel: UILabel!
    @IBOutlet weak var secondApproveLabel: UILabel!
    @IBOutlet weak var refusedLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectedDates: [Date] = []
    let viewModel = TimeOffViewModel()
    var weekendDays: [Int] = []
    var publicHolidays: [Date] = []
    var leaveTypes: [LeaveType] = []
    var filteredLeaveTypes: [LeaveType] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadHolidays()
        loadTimeOffData()
        setUpTexts()
        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "CollectionViewCell")
        NotificationCenter.default.addObserver(self,selector: #selector(languageChanged),name: NSNotification.Name("LanguageChanged"),object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadHolidays()
        loadTimeOffData()
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func languageChanged() {
        setUpTexts()
    }

    private func loadHolidays() {
        guard let token = UserDefaults.standard.employeeToken else { return }
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
            }
        }
    }
    
    private func loadTimeOffData() {
        guard let token = UserDefaults.standard.employeeToken else { return }
        viewModel.fetchTimeOff(token: token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let leaveTypes = response.result?.leaveTypes {
                        self?.leaveTypes = leaveTypes
                        self?.filteredLeaveTypes = leaveTypes.filter { leave in
                                !(leave.requiresAllocation == "no" || leave.remainingBalance == nil)
                            }
                        self?.collectionView.reloadData()
                    }
                case .failure(let error):
                    print("❌ TimeOff API Error:", error)
                }
            }
        }
    }
}

extension TimeOffViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDates.append(date)
        navigateToTimeOffRequest()
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
            return UIColor.systemRed.withAlphaComponent(0.3)
        }
        if selectedDates.contains(date) {
            return .purple
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
        firstAprroveLabel.text = NSLocalizedString("first_approval", comment: "")
        secondApproveLabel.text = NSLocalizedString("second_approval", comment: "")
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
        calender.appearance.headerTitleColor = UIColor.fromHex("90476F")
        calender.appearance.weekdayTextColor = UIColor.fromHex("90476F")
        calender.reloadData()
    }
    
    func navigateToTimeOffRequest() {
        let timeOffRequestVC = TimeOffRequestViewController()
      //  timeOffRequestVC.leaveTypes = leaveTypes
        timeOffRequestVC.filteredLeaveTypes = leaveTypes.filter { leave in
                !(leave.requiresAllocation == "yes" && leave.remainingBalance == nil)
            }
        print("timeOffRequestVC.filteredLeaveTypes: \(timeOffRequestVC.filteredLeaveTypes)")
        timeOffRequestVC.modalPresentationStyle = .overFullScreen
        timeOffRequestVC.modalTransitionStyle = .crossDissolve
        timeOffRequestVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        present(timeOffRequestVC, animated: true, completion: nil)
    }
}
