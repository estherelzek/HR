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
        setUpLisgnerstoViewModel()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLanguageChange),
            name: NSNotification.Name("LanguageChanged"),
            object: nil
        )
        print("📱 App became active — trying to resend offline requests...")
        NetworkManager.shared.resendOfflineRequests()
    }

    @objc private func handleLanguageChange() {
        reloadTexts()
    }
  

    @IBAction func checkingButtonTapped(_ sender: Any) {
        isCheckedIn.toggle()
        print("isCheckedIn: \(isCheckedIn)")
        viewModel.performCheckInOut(isCheckedIn: isCheckedIn, workedHours: workedHours)

        if NetworkListener.shared.isConnected {
            print("✅ Online → reloading texts")
            reloadTexts()
        } else {
            print("⚠️ Offline → request saved locally")
            
            let action = isCheckedIn ? "check-in" : "check-out"
            showAlert(
                title: "Offline Mode",
                message: "You're currently offline. Your \(action) request has been saved locally and will be sent automatically once you reconnect to the network."
            )
            goToTimeOff()
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
                       if response.result?.status == "success" {
                           self?.isCheckedIn = response.result?.attendanceStatus == "checked_in"
                           if let lastCheckInUTC = response.result?.lastCheckIn {
                               self?.lastCheckIn = lastCheckInUTC.toLocalDateString()
                           }

                           if let lastCheckOutUTC = response.result?.lastCheckOut ?? response.result?.checkOutTime {
                               self?.lastCheckOut = lastCheckOutUTC.toLocalDateString()
                           }

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

       private func handleAttendanceSuccess(_ response: AttendanceResponse) {
           if response.result?.attendanceStatus == "checked_in" {
               self.isCheckedIn = true
               self.lastCheckIn = response.result?.checkInTime
           } else if response.result?.attendanceStatus == "checked_out" {
               self.isCheckedIn = false
               self.lastCheckOut = response.result?.checkOutTime
               self.workedHours = response.result?.workedHours
           }
           self.reloadTexts()
       }
    
    func setUpLisgnerstoViewModel() {
        viewModel.onSuccess = { [weak self] response in
            DispatchQueue.main.async {
                self?.handleAttendanceSuccess(response)
            }
        }
        viewModel.onError = { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.showAlert(title: "Error", message: errorMessage)
            }
        }
        viewModel.onLocationError = { [weak self] message in
            DispatchQueue.main.async {
                self?.showAlert(title: "Location Error", message: message)
            }
        }
        viewModel.onShowAlert = { [weak self] message, _ in
               guard let self = self else { return }
               DispatchQueue.main.async {
                   let alert = UIAlertController(title: "Location Alert",message: message,preferredStyle: .alert)
                   alert.addAction(UIAlertAction(title: "OK", style: .default))
                   self.present(alert, animated: true)
            }
        }
    }
}

extension CheckingViewController {
    private func reloadTexts() {
        print("isCheckedIn : \(isCheckedIn)")
        if isCheckedIn {
            titleOfCheckingInOrOut.text = NSLocalizedString("checked_in_title", comment: "")
            checkingButton.setTitle(NSLocalizedString("checked_in_button", comment: ""), for: .normal)
            checkingButton.setImage(UIImage(named: "login"), for: .normal)

            if let lastCheckIn = lastCheckIn {
                print("lastCheckIn esther : \(lastCheckIn)")
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
            checkingButton.setImage(UIImage(named: "logout"), for: .normal)

            if let lastCheckOut = lastCheckOut, let hours = workedHours {
                print("lastCheckOut esther : \(lastCheckOut)")
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
}

