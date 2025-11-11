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
  //  @IBOutlet weak var requestData: UIStackView!
 //   @IBOutlet weak var coloredButton: InspectableButton!
   // @IBOutlet weak var ActionButton: InspectableButton!
    @IBOutlet weak var contentView: InspectableView!
    @IBOutlet var outSideView: UIView!
   // @IBOutlet weak var numberOfAnnualLeaveLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    private let viewModel = EmployeeUnlinkTimeOffViewModel()
    private var cancellables = Set<AnyCancellable>()
    var leaveId: Int?
    var  parentObject: TimeOffViewController?
    var selectedDate: Date?
    var allRecords: EmployeeTimeOffResult? // ⬅️ pass all records here
        var filteredRecords: [LeaveRecord] = [] // ⬅️ will hold records of selected day

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTexts()
        configureTableView()
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
    
    private func filterRecordsForSelectedDate() {
           guard let selectedDate = selectedDate else { return }
           guard let records = allRecords else { return }

           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy-MM-dd"
           let targetDateString = dateFormatter.string(from: selectedDate)
           let dailyMatches = records.records.dailyRecords.filter { $0.startDate == targetDateString }
           let hourlyMatches = records.records.hourlyRecords.filter { $0.leaveDay == targetDateString }
           filteredRecords = dailyMatches + hourlyMatches
           print("🗓 Found \(filteredRecords.count) records for \(targetDateString)")
           tableView.reloadData()
       }
    
    @IBAction func creatAnotherOneButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
        parentObject?.navigateToTimeOffRequest(selectedDate: selectedDate)
    }
    
    @objc private func handleOutsideTap(_ gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: contentView)
        if !contentView.bounds.contains(touchPoint) {
            dismiss(animated: true, completion: nil)
        }
    }

    func setUpTexts() {
           tilteLabel.text = NSLocalizedString("pending_approval", comment: "")
           let formatter = DateFormatter()
           formatter.dateStyle = .long
           formatter.timeStyle = .none
           if let selectedDate = selectedDate {
               dateLabel.text = formatter.string(from: selectedDate)
           }
        if LanguageManager.shared.currentLanguage() == "ar" {
            formatter.locale = Locale(identifier: "ar")
        } else {
            formatter.locale = Locale(identifier: "en")
        }
       }
       
    @objc private func languageChanged() {
        setUpTexts()
       }
    
    func fillTextFields(record: DailyRecord){
        dateLabel.text = "\(record.startDate) : \(record.endDate)"
    }
    
    private func configureTableView() {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UINib(nibName: "resultTableViewCell", bundle: nil), forCellReuseIdentifier: "resultCell")
        }
    
    func fillTextFields(record: LeaveRecord) {
        if let daily = record as? DailyRecord {
            dateLabel.text = "\(daily.startDate) : \(daily.endDate)"
            leaveId = daily.leaveID
            print("Daily leave for \(daily.durationDays) days")
        } else if let hourly = record as? HourlyRecord {
            let from = hourly.requestHourFrom.formattedHour(using: hourly.leaveDay)
            let to = hourly.requestHourTo.formattedHour(using: hourly.leaveDay)

            dateLabel.text = "\(hourly.leaveDay) | \(from) → \(to)"
            dateLabel.text = "\(hourly.leaveDay) | \(from) → \(to)"
            leaveId = hourly.leaveID
            print("Hourly leave for \(hourly.durationHours) hours")
        }
    }
}
extension ResultOfRequestAlartViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRecords.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as? resultTableViewCell else {
            return UITableViewCell()
        }

        let record = filteredRecords[indexPath.row]
        var leaveId: Int?

        if let daily = record as? DailyRecord {
            cell.numberOfAnnualLeaveLabel.text = "\(daily.leaveType): \(daily.durationDays) day(s)"
            cell.statusLabel.text = "Status: \(daily.state)"
            cell.periodLabel.text = "From: \(daily.startDate) -> To: \(daily.endDate)"
            cell.coloredButton.drawLeaveState(daily.state, colorHex: daily.color ?? "#B7F73E")
            leaveId = daily.leaveID
        } else if let hourly = record as? HourlyRecord {
            cell.numberOfAnnualLeaveLabel.text = "\(hourly.leaveType): \(hourly.durationHours) hour(s)"
            cell.statusLabel.text = "Status: \(hourly.state)"
            cell.periodLabel.text = "From: \(hourly.startDate) -> To: \(hourly.endDate)"
            cell.coloredButton.drawLeaveState(hourly.state, colorHex: hourly.color ?? "#B7F73E")
            leaveId = hourly.leaveID
        }
        cell.leaveId = leaveId
        cell.onDeleteTapped = { [weak self] id in
            guard let self = self else { return }
            self.deleteLeave(withId: id)
        }
        return cell
    }

    private func deleteLeave(withId id: Int) {
        guard let token = UserDefaults.standard.string(forKey: "employeeToken") else { return }
        print("Deleting leave with id: \(id)")
        viewModel.unlinkDraftLeave(token: token, leaveId: id)
        viewModel.$success
            .dropFirst()
            .sink { [weak self] isSuccess in
                guard let self = self else { return }

                if isSuccess {
                    self.showAlert(
                        title: "Success",
                        message: self.viewModel.apiMessage ?? "Leave cancelled successfully"
                    ) {
                        self.filterRecordsForSelectedDate() // 🔁 reload filtered list
                    }
                } else {
                    self.showAlert(
                        title: "Error",
                        message: self.viewModel.apiMessage ?? "Unable to cancel request"
                    )
                }
            }
            .store(in: &cancellables)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let record = filteredRecords[indexPath.row]
        print("Selected record:", record)
    }
  
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
          return 120
      }
}
