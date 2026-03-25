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

        NetworkManager.shared.resendOfflineRequests {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.fetchAttendanceStatus()
            }
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
        isLoadingAttendance = true
        checkingButton.isEnabled = false
        // Fetch latest attendance status first
        fetchAttendanceStatus { [weak self] in
            guard let self = self else { return }
            self.isLoadingAttendance = false
            // Confirm check-out if already checked in
            if self.isCheckedIn {
                let hoursText = self.workedHours != nil ? String(format: "%.2f hours", self.workedHours!) : NSLocalizedString("unknown", comment: "")
                
                let title = NSLocalizedString("confirm_checkout_title", comment: "")
                let messageFormat = NSLocalizedString("confirm_checkout_message", comment: "")
                let message = String(format: messageFormat, hoursText)
                
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("cancel_button", comment: ""), style: .cancel) { _ in
                    self.finishLoadingUI()
                })
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("confirm_button", comment: ""), style: .destructive) { _ in
                    self.performCheckInOut(isCheckedIn: true)
                })
                
                self.present(alert, animated: true)
            } else {
                // Direct check-in
                self.performCheckInOut(isCheckedIn: false)
            }
        }
        showAttendanceProcessingMessage(for: isCheckedIn ? "check_out" : "check_in")
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
                        self.finishLoadingUI()
                    }
                } else {
                    print("⚠️ Offline → request saved locally")
                    
                    let now = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // match backend format if needed
                    
                    let currentTimeString = formatter.string(from: now)
                    
                    if self.isCheckedIn {
                        self.lastCheckIn = currentTimeString
                        self.workedHours = nil
                    } else {
                        self.lastCheckOut = currentTimeString
                        
                        if let checkInString = self.lastCheckIn,
                           let checkInDate = formatter.date(from: checkInString) {
                            let hours = now.timeIntervalSince(checkInDate) / 3600
                            self.workedHours = round(hours * 100) / 100
                        }
                    }
                    
                    self.reloadTexts()
                    
                    self.showAlert(
                        title: "Offline Mode",
                        message: self.isCheckedIn
                        ? "You're offline. Check-in saved locally and will sync when online."
                        : "You're offline. Check-out saved locally and will sync when online."
                    )
                    
                    self.finishLoadingUI()
                }
            }
        }
    }

    private func finishLoadingUI() {
        isLoadingAttendance = false
        checkingButton.isEnabled = true
        reloadTexts()
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
//                    self.showAlert(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("weak_network_message", comment: "Alert shown when network is weak"))
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
                self.showAlert(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("weak_network_message", comment: "Alert shown when network is weak"))
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
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.handleAttendanceSuccess(response)
                
                // Cancel reminder if checked out
                if response.result?.attendanceStatus == "checked_out" {
                    NotificationManager.shared.cancelCheckoutReminder()
                }
                
                self.finishLoadingUI()
            }
        }
        
        // ✅ GENERAL ERRORS
        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.finishLoadingUI()
                
                let lowercasedMessage = message.lowercased()
                
                // 🔹 1️⃣ Handle 5-minute restriction (backend sends wrong code sometimes)
                if lowercasedMessage.contains("5 minute") {
                    self.showAlert(
                        title: NSLocalizedString("alert_warning_title", comment: ""),
                        message: NSLocalizedString("error_wait_5_minutes", comment: "")
                    )
                    return
                }
                
                // 🔹 2️⃣ Handle token expiration
                if lowercasedMessage.contains("token") ||
                   lowercasedMessage.contains("expired") {
                    
                    if let token = UserDefaults.standard.string(forKey: "employeeToken") {
                        self.handleTokenExpiry(token: token)
                    } else {
                        self.showAlert(
                            title: "Session Expired",
                            message:NSLocalizedString("session_expired", comment: "")
                               
                        )
                    }
                    return
                }
                
                // 🔹 3️⃣ Default warning
                self.showAlert(title: NSLocalizedString("alert_warning_title", comment: ""), message: "message")
            }
        }
        
        
        // ✅ LOCATION ERRORS (Protected Against Backend Mistake)
        viewModel.onLocationError = { [weak self] message in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.finishLoadingUI()
                
                let lowercasedMessage = message.lowercased()
                
                // 🚫 Backend bug protection:
                // If message is about 5 minutes, DO NOT treat as location error
                if lowercasedMessage.contains("5 minute") {
                    self.showAlert(
                        title: NSLocalizedString("alert_warning_title", comment: ""),
                        message: "Please wait 5 minutes before performing this action again."
                    )
                    return
                }
                
                // ✅ Real location problem
                self.showAlert(
                    title: "Location Error",
                    message: message.isEmpty
                    ? "Unable to verify your location. Please try again."
                    : message
                )
            }
        }
        
        
        // ✅ GENERIC ALERT (Used for special cases like GPS restriction)
        viewModel.onShowAlert = { [weak self] message, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.finishLoadingUI()
                
                let alert = UIAlertController(
                    title: "Alert",
                    message: message,
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("ok_button", comment: ""), style: .default))
                self.present(alert, animated: true)
            }
        }
    }


    private func handleAttendanceSuccess(_ response: AttendanceResponse) {
        if response.result?.attendanceStatus == "checked_in" {
            isCheckedIn = true
            lastCheckIn = response.result?.checkInTime
            
            // Use backend scheduled hours in normal behavior.
            // NotificationManager can temporarily override this for local testing.
            let requiredHours = response.result?.todayScheduledHours ?? 8.0
            print("📅 Checkout reminder will be scheduled for \(requiredHours) hours after check-in")
            print("🕐 Check-in time: \(response.result?.checkInTime ?? "nil")")
            
            if let checkInTime = response.result?.checkInTime {
                NotificationManager.shared.scheduleCheckoutReminder(
                    checkInTime: checkInTime,
                    requiredHours: requiredHours
                )
            }
            
        } else {
            isCheckedIn = false
            lastCheckOut = response.result?.checkOutTime
            workedHours = response.result?.workedHours
            NotificationManager.shared.cancelCheckoutReminder()
        }
        reloadTexts()
    }
}
