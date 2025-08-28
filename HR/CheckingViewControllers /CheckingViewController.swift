//
//  CheckingViewController.swift
//  HR
//
//  Created by Esther Elzek on 20/08/2025.
//

import UIKit

class CheckingViewController: UIViewController {
    
    @IBOutlet weak var titleOfCheckingInOrOut: UILabel!
    @IBOutlet weak var discreptionOfCurrecntAttendence: UILabel!
    @IBOutlet weak var checkingButton: InspectableButton!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    private let viewModel = AttendanceViewModel()
    private var isCheckedIn = false
    private var lastCheckIn: String?
    private var lastCheckOut: String?
    private var workedHours: Double?

    override func viewDidLoad() {
        super.viewDidLoad()
        loader.startAnimating()
        fetchAttendanceStatus()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLanguageChange),
            name: NSNotification.Name("LanguageChanged"),
            object: nil
        )
    }

    @objc private func handleLanguageChange() {
        reloadTexts()
    }

    @IBAction func checkingButtonTapped(_ sender: Any) {
        let token = UserDefaults.standard.string(forKey: "employeeToken") ?? ""
        let action = isCheckedIn ? "check_out" : "check_in"
        if action == "check_out", let hours = workedHours, hours < 8 {
            showAttentionAlert()
           } else {
               performAttendanceAction(action, token: token)
           }
    }

    private func fetchAttendanceStatus() {
        guard let token = UserDefaults.standard.string(forKey: "employeeToken") else {
            showAlert(title: "Error", message: "No token found. Please log in again.")
            return
        }

        viewModel.status(token: token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("📦 Full Response: \(response)")
                    if response.result?.status == "success" {
                        let attendanceStatus = response.result?.attendanceStatus
                        if attendanceStatus == "checked_in" {
                            self?.isCheckedIn = true
                        } else {
                            self?.isCheckedIn = false
                        }
                        self?.lastCheckIn = response.result?.lastCheckIn
                        self?.lastCheckOut = response.result?.lastCheckOut ?? response.result?.checkOutTime
                        self?.workedHours = response.result?.workedHours
                    }
                    self?.reloadTexts()
                    self?.loader.stopAnimating()
                    self?.loader.hidesWhenStopped = true
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    private func performAttendanceAction(_ action: String, token: String) {
        let call: (String, @escaping (Result<AttendanceResponse, APIError>) -> Void) -> Void

        switch action {
        case "check_in":
            call = viewModel.checkIn
        case "check_out":
            call = viewModel.checkOut
        default:
            return
        }

        call(token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("📦 Action Response: \(response)")
                    self?.showAlert(title: "Success", message: response.result?.message ?? "") {
                        self?.navigateToTimeOffVC()
                    }

                    let attendanceStatus = response.result?.attendanceStatus
                    print("🔍 attendanceStatus after action: \(attendanceStatus ?? "nil")")
                    if attendanceStatus == "checked_in" {
                        self?.isCheckedIn = true
                        self?.lastCheckIn = response.result?.checkInTime
                    } else if attendanceStatus == "checked_out" {
                        self?.isCheckedIn = false
                        self?.lastCheckOut = response.result?.checkOutTime
                        self?.workedHours = response.result?.workedHours
                    }
                    print("✅ isCheckedIn = \(self?.isCheckedIn ?? false)")
                    self?.reloadTexts()

                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
}

extension CheckingViewController {
    private func reloadTexts() {
        if isCheckedIn {
            titleOfCheckingInOrOut.text = NSLocalizedString("checked_in_title", comment: "")
            checkingButton.setTitle(NSLocalizedString("checked_in_button", comment: ""), for: .normal)

            if let lastCheckIn = lastCheckIn {
                discreptionOfCurrecntAttendence.text = String(
                    format: NSLocalizedString("checked_in_description_with_time", comment: ""),
                    lastCheckIn
                )
            } else {
                discreptionOfCurrecntAttendence.text = NSLocalizedString("checked_in_description", comment: "")
            }

        } else {
            titleOfCheckingInOrOut.text = NSLocalizedString("checked_out_title", comment: "")
            checkingButton.setTitle(NSLocalizedString("checked_out_button", comment: ""), for: .normal)

            if let lastCheckOut = lastCheckOut, let hours = workedHours {
                discreptionOfCurrecntAttendence.text = String(
                    format: NSLocalizedString("checked_out_description_with_time", comment: ""),
                    lastCheckOut,
                    hours
                )
            } else {
                discreptionOfCurrecntAttendence.text = NSLocalizedString("checked_out_description", comment: "")
            }
        }
    }

    func navigateToTimeOffVC() {
        let timeOffVC = TimeOffViewController(nibName: "TimeOffViewController", bundle: nil)
        timeOffVC.modalPresentationStyle = .fullScreen
        present(timeOffVC, animated: true, completion: nil)
    }
   
    private func showAttentionAlert() {
        let attentionVC = AttentionViewController(nibName: "AttentionViewController", bundle: nil)
        attentionVC.modalPresentationStyle = .overFullScreen
        attentionVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        attentionVC.modalTransitionStyle = .crossDissolve
        attentionVC.workedHoursText = String(format: "%.2f", workedHours ?? 0)
        attentionVC.onConfirm = { [weak self] in
            guard let token = UserDefaults.standard.string(forKey: "employeeToken") else { return }
            self?.performAttendanceAction("check_out", token: token)
        }
        present(attentionVC, animated: true, completion: nil)
    }
}
