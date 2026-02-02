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
    
    private var isLoadingAttendance: Bool = false {
        didSet { updateLoaderState() }
    }
    private var isFetchingStatus: Bool = false {
        didSet { updateLoaderState() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader.startAnimating()
        setUpLisgnerstoViewModel()
        
        viewModel.onLocationPermissionDenied = { [weak self] in
            DispatchQueue.main.async {
                self?.isLoadingAttendance = false
                self?.showLocationPermissionAlert()
            }
        }

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

    // MARK: - Button Action
    @IBAction func checkingButtonTapped(_ sender: Any) {
        // Disable UI and show processing message
        isLoadingAttendance = true
        showAttendanceProcessingMessage(for: isCheckedIn ? "check_out" : "check_in")
        checkingButton.isEnabled = false
        
        // Confirm check-out if already checked in
        if isCheckedIn {
            let hoursText = workedHours != nil ? String(format: "%.2f hours", workedHours!) : "Unknown"
            let alert = UIAlertController(
                title: "Confirm Check-Out",
                message: "You’ve worked \(hoursText) today. Are you sure you want to check out?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
                self?.isLoadingAttendance = false
                self?.checkingButton.isEnabled = true
            })
            alert.addAction(UIAlertAction(title: "Check Out", style: .destructive) { [weak self] _ in
                self?.performCheckInOut(isCheckedIn: true)
            })
            present(alert, animated: true)
        } else {
            // Direct check-in
            performCheckInOut(isCheckedIn: false)
        }
    }
    
    private func performCheckInOut(isCheckedIn: Bool) {
        self.isCheckedIn = !isCheckedIn
        isLoadingAttendance = true

        viewModel.performCheckInOut(isCheckedIn: self.isCheckedIn, workedHours: workedHours) { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if NetworkListener.shared.isConnected {
                    print("✅ Online → fetching status")
                    self.fetchAttendanceStatus {
                        self.isLoadingAttendance = false
                        self.reloadTexts()
                    }
                } else {
                    print("⚠️ Offline → request saved locally")
                    let def = UserDefaults.standard.string(forKey: "clockDiffMinutes") ?? "0"
                    print("def: \(def)")
                    if def != "-1000" {
                        self.showAlert(
                            title: "Offline Mode",
                            message: self.isCheckedIn
                            ? "You're currently offline. Your check-in request has been saved locally and will be sent automatically once you reconnect to the network."
                            : "You're currently offline. Your check-out request has been saved locally and will be sent automatically once you reconnect to the network."
                        )
                    }
                    self.isLoadingAttendance = false
                    self.reloadTexts()
                }
            }
        }
    }

    // MARK: - Fetch Attendance Status
    private func fetchAttendanceStatus(completion: (() -> Void)? = nil) {
        isFetchingStatus = true
        guard let token = UserDefaults.standard.string(forKey: "employeeToken") else {
            isFetchingStatus = false
            showAlert(title: "Error", message: "No token found. Please log in again.")
            completion?()
            return
        }
        
        viewModel.status(token: token) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isFetchingStatus = false
                
                switch result {
                case .success(let response):
                    if response.result?.status == "success" {
                        self.isCheckedIn = response.result?.attendanceStatus == "checked_in"
                        self.lastCheckIn = response.result?.lastCheckIn
                        self.lastCheckOut = response.result?.lastCheckOut ?? response.result?.checkOutTime
                        self.workedHours = response.result?.workedHours
                        self.reloadTexts()
                    } else if response.result?.errorCode == "INVALID_TOKEN" || response.result?.errorCode == "TOKEN_EXPIRED" {
                        self.handleTokenExpiry(token: token)
                    } else {
                        self.showAlert(title: "Attendance Error", message: response.result?.message ?? "Unknown error")
                    }
                case .failure(let error):
                    print("❌ Request failed: \(error.localizedDescription)")
                    self.showAlert(title: "Error", message: "Weak Network Connection. Please try again.")
                }
                completion?()
            }
        }
    }
    
    private func handleTokenExpiry(token: String) {
        guard let companyIdKey = UserDefaults.standard.string(forKey: "companyIdKey"),
              let apiKeyKey = UserDefaults.standard.string(forKey: "apiKeyKey") else { return }
        let tokenVM = GenerateTokenViewModel()
        tokenVM.generateNewToken(employeeToken: token, companyId: companyIdKey, apiKey: apiKeyKey) { [weak self] in
            guard let self = self else { return }
            if let newToken = tokenVM.tokenResponse?.newToken {
                UserDefaults.standard.set(newToken, forKey: "employeeToken")
                self.fetchAttendanceStatus()
            } else if let error = tokenVM.errorMessage {
                print("❌ Failed to regenerate token: \(error)")
                self.showAlert(title: "Error", message: "Weak Network Connection. Please try again.")
            }
        }
    }
    
    // MARK: - UI Updates
    private func reloadTexts() {
        if isCheckedIn {
            titleOfCheckingInOrOut.text = NSLocalizedString("checked_in_title", comment: "")
            checkingButton.setTitle(NSLocalizedString("checked_in_button", comment: ""), for: .normal)
            checkingButton.setImage(UIImage(named: "login"), for: .normal)
            
            if let lastCheckIn = lastCheckIn?.toLocalDateString() {
                discreptionOfCurrecntAttendence.text = String(format: NSLocalizedString("checked_in_description_with_time", comment: ""), lastCheckIn)
            } else {
                discreptionOfCurrecntAttendence.text = NSLocalizedString("checked_in_description", comment: "")
            }
        } else {
            titleOfCheckingInOrOut.text = NSLocalizedString("checked_out_title", comment: "")
            checkingButton.setTitle(NSLocalizedString("checked_out_button", comment: ""), for: .normal)
            checkingButton.setImage(UIImage(named: "logout"), for: .normal)
            
            if let lastCheckOut = lastCheckOut?.toLocalDateString(), let hours = workedHours {
                discreptionOfCurrecntAttendence.text = String(format: NSLocalizedString("checked_out_description_with_time", comment: ""), lastCheckOut, hours)
            } else {
                discreptionOfCurrecntAttendence.text = NSLocalizedString("checked_out_description", comment: "")
            }
        }
    }
    
    private func showAttendanceProcessingMessage(for action: String) {
        discreptionOfCurrecntAttendence.text = NSLocalizedString("attendance_processing", comment: "")
        titleOfCheckingInOrOut.text = action == "check_in" ? NSLocalizedString("checking_in_title", comment: "") : NSLocalizedString("checking_out_title", comment: "")
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

    private func updateLoaderState() {
        let shouldShow = isLoadingAttendance || isFetchingStatus
        loader.isHidden = !shouldShow
        if shouldShow {
            loader.startAnimating()
        } else {
            loader.stopAnimating()
        }
        view.isUserInteractionEnabled = !shouldShow
    }

    private func setUpLisgnerstoViewModel() {
        viewModel.onSuccess = { [weak self] response in
            DispatchQueue.main.async { self?.handleAttendanceSuccess(response) }
        }
        viewModel.onError = { [weak self] _ in
            DispatchQueue.main.async { self?.showAlert(title: "Error", message: "Weak Network Connection. Please try again.") }
        }
        viewModel.onLocationError = { [weak self] _ in
            DispatchQueue.main.async { self?.showAlert(title: "Location Error", message: "Now We Got Location Permission. Please try again.") }
        }
        viewModel.onShowAlert = { [weak self] message, _ in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Location Alert", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
    
    private func handleAttendanceSuccess(_ response: AttendanceResponse) {
        if response.result?.attendanceStatus == "checked_in" {
            isCheckedIn = true
            lastCheckIn = response.result?.checkInTime
        } else {
            isCheckedIn = false
            lastCheckOut = response.result?.checkOutTime
            workedHours = response.result?.workedHours
        }
        reloadTexts()
    }
}
