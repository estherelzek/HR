//
//  CheckingVC.swift
//  HR
//
//  Created by Esther Elzek on 20/10/2025.
//

import UIKit

class CheckingVC: UIViewController {
    @IBOutlet weak var titleOfCheckingInOrOut: UILabel!
    @IBOutlet weak var discreptionOfCurrecntAttendence: UILabel!
    @IBOutlet weak var checkingButton: InspectableButton!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    private let viewModel = AttendanceViewModel()
    private var isCheckedIn = false
    private var lastCheckIn: String?
    private var lastCheckOut: String?
    private var workedHours: Double?
    private let locationService = LocationService()

    override func viewDidLoad() {
        super.viewDidLoad()

        // 🔴 THIS IS WHERE IT GOES
        viewModel.onLocationPermissionDenied = { [weak self] in
                DispatchQueue.main.async {
                    self?.hideLoader()
                    self?.showLocationPermissionAlert()
                }
            }

        loader.startAnimating()
        setUpLisgnerstoViewModel()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLanguageChange),
            name: NSNotification.Name("LanguageChanged"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkBecameReachable),
            name: .networkReachable,
            object: nil
        )

        NetworkManager.shared.resendOfflineRequests { [weak self] in
            self?.fetchAttendanceStatus()
        }

        calculateClockDifference()
    }



    @objc private func networkBecameReachable() {
        print("🌐 Network became reachable → resending offline requests...")
        NetworkManager.shared.resendOfflineRequests()
    }


    @objc private func handleLanguageChange() {
        reloadTexts()
    }
  

    @IBAction func checkingButtonTapped(_ sender: Any) {
        showLoader() // 🔹 show loader immediately

        self.fetchAttendanceStatus() // refresh status first

        if isCheckedIn {
            let hoursText: String
            if let hours = workedHours {
                hoursText = String(format: "%.2f hours", hours)
            } else {
                hoursText = "Unknown"
            }

            let alert = UIAlertController(
                title: "Confirm Check-Out",
                message: "You’ve worked \(hoursText) today. Are you sure you want to check out?",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
                self?.hideLoader() // 🔹 hide loader if cancelled
            })

            alert.addAction(UIAlertAction(title: "Check Out", style: .destructive) { [weak self] _ in
                guard let self = self else { return }

                self.isCheckedIn.toggle()
                print("isCheckedIn after confirmation: \(self.isCheckedIn)")

                self.viewModel.performCheckInOut(isCheckedIn: self.isCheckedIn, workedHours: self.workedHours) {
                    // ✅ API completed
                    DispatchQueue.main.async {
                        if NetworkListener.shared.isConnected {
                            print("✅ Online → fetching status")
                            self.fetchAttendanceStatus()
                            self.reloadTexts()
                        } else {
                            print("⚠️ Offline → request saved locally")
                            let def = UserDefaults.standard.string(forKey: "clockDiffMinutes") ?? "0"
                            print("def: \(def)")
                            if def != "-1000" {
                                self.showAlert(
                                    title: "Offline Mode",
                                    message: "You're currently offline. Your check-out request has been saved locally and will be sent automatically once you reconnect to the network."
                                )
                            }
                            self.hideLoader() // hide loader after offline handling
                        }
                    }
                }
            })

            present(alert, animated: true)

        } else {
            // Check-In
            isCheckedIn.toggle()
            print("isCheckedIn after check-in: \(isCheckedIn)")

            viewModel.performCheckInOut(isCheckedIn: isCheckedIn, workedHours: workedHours) {
                DispatchQueue.main.async {
                    if NetworkListener.shared.isConnected {
                        print("✅ Online → fetching status")
                        self.fetchAttendanceStatus()
                        self.reloadTexts()
                    } else {
                        print("⚠️ Offline → request saved locally")
                        let def = UserDefaults.standard.string(forKey: "clockDiffMinutes") ?? "0"
                        print("def: \(def)")
                        if def != "-1000" {
                            self.showAlert(
                                title: "Offline Mode",
                                message: "You're currently offline. Your check-in request has been saved locally and will be sent automatically once you reconnect to the network."
                            )
                        }
                        self.hideLoader() // hide loader after offline handling
                    }
                }
            }
        }
    }

    // MARK: - Fetch Attendance Status with loader
    private func fetchAttendanceStatus() {
        showLoader() // 🔹 show loader

        guard let token = UserDefaults.standard.string(forKey: "employeeToken") else {
            hideLoader()
            showAlert(title: "Error", message: "No token found. Please log in again.")
            return
        }
        guard let companyIdKey = UserDefaults.standard.string(forKey: "companyIdKey") else {
            hideLoader()
            showAlert(title: "Error", message: "No companyIdKey found. Please log in again.")
            return
        }
        guard let apiKeyKey = UserDefaults.standard.string(forKey: "apiKeyKey") else {
            hideLoader()
            showAlert(title: "Error", message: "No apiKeyKey found. Please log in again.")
            return
        }

        viewModel.status(token: token) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.hideLoader() // 🔹 hide loader when API returns

                switch result {
                case .success(let response):
                    if response.result?.status == "success" {
                        self.isCheckedIn = response.result?.attendanceStatus == "checked_in"
                        self.lastCheckIn = response.result?.lastCheckIn
                        self.lastCheckOut = response.result?.lastCheckOut ?? response.result?.checkOutTime
                        self.workedHours = response.result?.workedHours
                        self.reloadTexts()
                    } else if response.result?.errorCode == "INVALID_TOKEN" || response.result?.errorCode == "TOKEN_EXPIRED" {
                        // 🔁 Regenerate token
                        let tokenVM = GenerateTokenViewModel()
                        tokenVM.generateNewToken(employeeToken: token, companyId: companyIdKey, apiKey: apiKeyKey) {
                            if let newToken = tokenVM.tokenResponse?.newToken {
                                print("✅ New token generated: \(newToken)")
                                UserDefaults.standard.set(newToken, forKey: "employeeToken")
                                self.fetchAttendanceStatus() // retry
                            } else if let error = tokenVM.errorMessage {
                                print("❌ Failed to regenerate token: \(error)")
                                self.goToScanVC()
                                self.showAlert(title: "Error", message: "Weak Network Connection. Please try again.")
                            }
                        }
                    } else {
                        self.showAlert(title: "Attendance Error", message: response.result?.message ?? "Unknown error")
                    }

                case .failure(let error):
                    print("❌ Request failed: \(error.localizedDescription)")
                    self.showAlert(title: "Error", message: "Weak Network Connection. Please try again.")
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
     //      self.hideLoader()

       }
    
    func setUpLisgnerstoViewModel() {
        viewModel.onSuccess = { [weak self] response in
            DispatchQueue.main.async {
                self?.handleAttendanceSuccess(response)
            }
        }
        viewModel.onError = { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.showAlert(title: "Error", message: "Weak Network Connection. Please try again.")
            }
        }
        viewModel.onLocationError = { [weak self] message in
            DispatchQueue.main.async {
                self?.showAlert(title: "Location Error", message: "Now We Got Location Permission. Please try again.")
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

extension CheckingVC {
    private func reloadTexts() {
        print("isCheckedIn : \(isCheckedIn)")
        if isCheckedIn {
           titleOfCheckingInOrOut.text = NSLocalizedString("checked_in_title", comment: "")
            checkingButton.setTitle(NSLocalizedString("checked_in_button", comment: ""), for: .normal)
            checkingButton.setImage(UIImage(named: "login"), for: .normal)

            if let lastCheckIn = lastCheckIn?.toLocalDateString() {
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

            if let lastCheckOut = lastCheckOut?.toLocalDateString(), let hours = workedHours {
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
    private func showLocationPermissionAlert() {
        let alert = UIAlertController(
            title: "Location Permission Required",
            message: "Location access is required to check in or check out. Please enable it from Settings.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })

        present(alert, animated: true)
    }
    private func showLoader() {
        loader.isHidden = false
        loader.startAnimating()
        view.isUserInteractionEnabled = false
    }

    private func hideLoader() {
        loader.stopAnimating()
        loader.isHidden = true
        view.isUserInteractionEnabled = true
    }

}
