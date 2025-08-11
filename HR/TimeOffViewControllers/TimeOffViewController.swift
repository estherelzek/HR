//
//  TimeOffViewController.swift
//  HR
//
//  Created by Esther Elzek on 10/08/2025.
//

import UIKit
import FSCalendar

class TimeOffViewController: UIViewController {

    @IBOutlet weak var annualLeavesLabel: UILabel!
    @IBOutlet weak var ValidAnnualDateLabel: UILabel!
    @IBOutlet weak var permissionHoursLabel: UILabel!
    @IBOutlet weak var validPermissionDate: UILabel!
    @IBOutlet weak var calender: FSCalendar!
    
    var selectedDates: [Date] = []
    override func viewDidLoad() {
        super.viewDidLoad()
       // view.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        calender.delegate = self
        calender.dataSource = self
        calender.appearance.headerTitleColor = UIColor.fromHex("90476F")
        calender.appearance.weekdayTextColor =  UIColor.fromHex("90476F")
    }
    

    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
    
extension TimeOffViewController: FSCalendarDelegate, FSCalendarDataSource {
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
                selectedDates.append(date)
                print("Selected: \(date)")
                navigateToResultOfRequest()
            }

            func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
                return selectedDates.contains(date) ? .purple : nil
            }
    
    func navigateToResultOfRequest() {
//        let resultOfRequestVC = ResultOfRequestAlartViewController(nibName: "ResultOfRequestAlartViewController", bundle: nil)
//        resultOfRequestVC.modalPresentationStyle = .fullScreen
//        present(resultOfRequestVC, animated: true, completion: nil)
        let resultOfRequestVC = ResultOfRequestAlartViewController()
        resultOfRequestVC.modalPresentationStyle = .overFullScreen
        resultOfRequestVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        resultOfRequestVC.modalTransitionStyle = .crossDissolve
        present(resultOfRequestVC, animated: true, completion: nil)

  }
}
