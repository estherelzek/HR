//
//  AttendanceViewModel.swift
//  HR
//
//  Created by Esther Elzek on 25/08/2025.
//

import Foundation
import CoreLocation
import UIKit

final class AttendanceViewModel {
    private let locationService = LocationService()
    // MARK: - Callbacks to VC
    var onShowAlert: ((String, @escaping () -> Void) -> Void)?
    var onSuccess: ((AttendanceResponse) -> Void)?
    var onError: ((String) -> Void)?
    var onLocationError: ((String) -> Void)?
    var onLocationPermissionDenied: (() -> Void)?
//    var onErrorMessage: ((String) -> Void)?   // 🔥 for alerts
        init() {
            locationService.onPermissionDenied = { [weak self] in
                self?.onLocationPermissionDenied?()
            }
        }
    // MARK: - Attendance Requests
    func checkIn(token: String, lat: String, lng: String, action_time: String ,completion: @escaping (Result<AttendanceResponse, APIError>) -> Void) {
        print("📤 Sending CHECK-IN request with token=\(token), lat=\(lat), lng=\(lng) , action_time=\(action_time)")
        let endpoint = API.employeeAttendance(action: "check_in", token: token, lat: lat, lng: lng, action_time: action_time)
        NetworkManager.shared.requestDecodable(endpoint, as: AttendanceResponse.self, completion: completion)
    }

    func checkOut(token: String, lat: String, lng: String, action_time: String , completion: @escaping (Result<AttendanceResponse, APIError>) -> Void) {
        print("📤 Sending CHECK-OUT request with token=\(token), lat=\(lat), lng=\(lng) , action_time=\(action_time)")
        let endpoint = API.employeeAttendance(action: "check_out", token: token, lat: lat, lng: lng, action_time: action_time)
        NetworkManager.shared.requestDecodable(endpoint, as: AttendanceResponse.self, completion: completion)
    }

    func status(token: String, completion: @escaping (Result<AttendanceResponse, APIError>) -> Void) {
        print("📤 Sending STATUS request with token=\(token)")
        let endpoint = API.employeeAttendance(action: "status", token: token, lat: nil, lng: nil)
        NetworkManager.shared.requestDecodable(endpoint, as: AttendanceResponse.self, completion: completion)
    }
    
    func getServerTime(token: String , completion: @escaping (Result<ServerTimeResponse, APIError>) -> Void) {
        print("📤 Sending ServerTime request with token=\(token)")
        let endpoint = API.getServerTime(token: token, action: "server_time")
        NetworkManager.shared.requestDecodable(endpoint, as: ServerTimeResponse.self, completion: completion)
    }
    
    func performCheckInOut(isCheckedIn: Bool, workedHours: Double?, completion: @escaping () -> Void) {
        let def = UserDefaults.standard.string(forKey: "clockDiffMinutes") ?? "0"
        print("def: \(def)")
        let token = UserDefaults.standard.string(forKey: "employeeToken") ?? ""
        let action = isCheckedIn ? "check_in" : "check_out"

        print("🔘 performCheckInOut called → isCheckedIn=\(isCheckedIn), action=\(action), workedHours=\(String(describing: workedHours))")

        proceedAttendanceAction(action, token: token) { success in
            print(success ? "✅ \(action) completed successfully." : "❌ \(action) failed.")
            DispatchQueue.main.async {
                completion() // 🔹 Tell VC to hide loader / refresh status
            }
        }
    }

    private func proceedAttendanceAction(
        _ action: String,
        token: String,
        completion: @escaping (Bool) -> Void
    ) {
        print("📍 Requesting location for action = \(action)")

        locationService.requestLocation { [weak self] coordinate in
            guard let self = self else {
                completion(false)
                return
            }

            guard let userCoordinate = coordinate else {
                print("❌ Failed to fetch location - Cancelling attendance action")
                self.onLocationError?("Unable to fetch location. Please ensure location services are enabled.")
                completion(false)
                return
            }

            print("📍 User Location → lat: \(userCoordinate.latitude), lng: \(userCoordinate.longitude)")

            self.continueWithAttendanceFlow(
                action: action,
                token: token,
                userCoordinate: userCoordinate,
                completion: completion
            )
        }
    }

    private func continueWithAttendanceFlow(
        action: String,
        token: String,
        userCoordinate: CLLocationCoordinate2D,
        completion: @escaping (Bool) -> Void
    ) {
        let allBranches = UserDefaults.standard.companyBranches
        let allowedBranchIDs = UserDefaults.standard.allowedBranchIDs

        print("🏢 Total Company Branches: \(allBranches.count)")
        print("🟦 Employee allowed branches: \(allowedBranchIDs)")

        var matchedBranchID: Int?

        for branch in allBranches {
            let branchLocation = CLLocation(latitude: branch.latitude, longitude: branch.longitude)
            let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
            let distance = userLocation.distance(from: branchLocation)

            print("🔍 Branch \(branch.id) → dist: \(distance), allowed: \(branch.allowedDistance)")

            if distance <= branch.allowedDistance {
                matchedBranchID = branch.id
                print("✅ User inside branch ID \(branch.id)")
                break
            }
        }

        guard let branchID = matchedBranchID else {
            print("❌ User not inside any company branch")
            self.onShowAlert?("You are not inside any company location.", {})
            completion(false)
            return
        }

        let isAllowed = allowedBranchIDs.contains(branchID)

        if !isAllowed {
            print("⚠️ Branch \(branchID) is NOT allowed for employee")
            self.onShowAlert?(
                "This is not your allowed company location. Attendance will be recorded with a warning.",
                {}
            )
        }

        print("🟢 Proceeding with attendance → Branch \(branchID)")

        self.getServerTime(token: token) { result in
            switch result {
            case .success(let response):
                guard let serverTime = response.result?.serverTime else {
                    print("⚠️ Missing server time")
                    completion(false)
                    return
                }
                print("🕒 Server time: \(serverTime)")
                self.performAttendanceAction(
                    action: action,
                    token: token,
                    lat: "\(userCoordinate.latitude)",
                    lng: "\(userCoordinate.longitude)",
                    time: serverTime,
                    completion: completion
                )
            case .failure(let error):
                print("❌ Failed to get server time: \(error.localizedDescription)")
                completion(false)
            }
        }
    }

    private func performAttendanceAction(
        action: String,
        token: String,
        lat: String,
        lng: String,
        time: String,
        completion: @escaping (Bool) -> Void
    ) {
        if action == "check_in" {
            print("➡️ Calling checkIn API with time \(time)")
            self.checkIn(token: token, lat: lat, lng: lng, action_time: time) {
                self.handleResult($0, completion: completion)
            }
        } else {
            print("➡️ Calling checkOut API with time \(time)")
            self.checkOut(token: token, lat: lat, lng: lng, action_time: time) {
                self.handleResult($0, completion: completion)
            }
        }
    }

    func calculateClockDifferenceAndWait(completion: @escaping () -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "employeeToken") else {
            print("❌ No token found.")
            completion()
            return
        }

        getServerTime(token: token) { result in
            switch result {
            case .success(let response):
                guard let serverTimeString = response.result?.serverTime else {
                    print("❌ Server time missing in response.")
                    completion()
                    return
                }

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                formatter.timeZone = TimeZone(identifier: response.result?.timezone ?? "UTC")

                guard let serverDate = formatter.date(from: serverTimeString) else {
                    print("❌ Failed to parse server time: \(serverTimeString)")
                    completion()
                    return
                }

                let localDate = Date()
                let differenceInMinutes = localDate.timeIntervalSince(serverDate) / 60.0
                UserDefaults.standard.set(differenceInMinutes, forKey: "clockDiffMinutes")
                UserDefaults.standard.synchronize()

                print("✅ Clock diff recalculated: \(differenceInMinutes) minutes")
                completion() // ← Notify caller that we finished

            case .failure(let error):
                print("❌ Failed to recalculate server time: \(error)")
                completion()
            }
        }
    }

    // MARK: - Result Handling
    private func handleResult(_ result: Result<AttendanceResponse, APIError>, completion: @escaping (Bool) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "employeeToken") else {
//showAlert(title: "Error", message: "No token found. Please log in again.")
            return
        }
        guard let companyIdKey = UserDefaults.standard.string(forKey: "companyIdKey") else {
         //   showAlert(title: "Error", message: "No companyIdKey found. Please log in again.")
            return
        }
        guard let apiKeyKey = UserDefaults.standard.string(forKey: "apiKeyKey") else {
    //        showAlert(title: "Error", message: "No apiKeyKey found. Please log in again.")
            return
        }

        switch result {
        case .success(let response):
            print("✅ Attendance API success: \(response)")
            if response.result?.status == "success" {
                onSuccess?(response)
                completion(true)
            }else if response.result?.status == "error" {
                if  response.result?.errorCode == "INVALID_TOKEN" || response.result?.errorCode == "TOKEN_EXPIRED" {
                    // esther here
                    // 🔁 Generate new token and retry
                    let tokenVM = GenerateTokenViewModel()
                    tokenVM.generateNewToken(
                        employeeToken: token,
                        companyId: companyIdKey,
                        apiKey: apiKeyKey
                    ) { 
                        if let result = tokenVM.tokenResponse {
                            print("✅ New token generated: \(result.newToken)")
                            UserDefaults.standard.set(result.newToken, forKey: "employeeToken")
                            
                         //   // 🔁 Retry the call after getting new token
                        //    self.fetchAttendanceStatus()
                        } else if let error = tokenVM.errorMessage {
                            print("❌ Failed to regenerate token: \(error)")
                         //   self.showAlert(title: "Error", message: error)
                        }
                    }
                }

                
            }else {
                // here
                // here 
                onError?(response.result?.message ?? "Unknown error")
                completion(false)
            }
         
        case .failure(let error):
            print("❌ Attendance API failed: \(error.localizedDescription)")
        //    onError?(error.localizedDescription)
            completion(false)
        }
    }
}

// MARK: - Simplified Online Check (no offline saving)
extension AttendanceViewModel {

    func resendPending(token: String) {
        // No offline actions anymore
        print("📭 Offline resend skipped — offline storage disabled.")
    }
    
    private func getCurrentActionTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.string(from: Date())
    }
//    private func getCurrentActionTime() -> Date {
//        return Date() // Just return the current Date in UTC
//    }
    
    private func handleClockTamperingAlertAndRecalculate(action: String) {
        let message = "You’ve changed your device clock. Please reconnect to the internet before proceeding."
        print("🚫 Clock tampering detected — blocking offline check-in/out.")
        
        let alert = UIAlertController(title: "Clock Changed", message: message, preferredStyle: .alert)
        
        // Placeholder variable so we can reference it inside the closure
        var okAction: UIAlertAction!
        
        // Define the handler
        let okHandler: (UIAlertAction) -> Void = { [weak self] _ in
            guard let self = self else { return }
            print("🕒 User pressed OK — calling getServerTime()...")
            
            guard let token = UserDefaults.standard.string(forKey: "employeeToken") else {
                print("❌ No token found.")
                return
            }
            
            // Disable button and show spinner
            okAction.isEnabled = false
            let indicator = UIActivityIndicatorView(style: .medium)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            alert.view.addSubview(indicator)
            NSLayoutConstraint.activate([
                indicator.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
                indicator.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -45)
            ])
            indicator.startAnimating()
            
            // Call getServerTime until success
            self.getServerTime(token: token) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        if response.result?.status.lowercased() == "success" {
                            print("✅ Server time fetched successfully.")
                            indicator.stopAnimating()
                            alert.dismiss(animated: true) {
                                self.performCheckInOut(isCheckedIn: action == "check_in", workedHours: nil) {
                                    print("successfully checked \(action)")
                                }
                            }
                        } else {
                            print("⚠️ Server returned status: \(response.result?.status ?? "unknown")")
                            indicator.stopAnimating()
                            okAction.isEnabled = true // allow retry
                        }
                        
                    case .failure(let error):
                        print("❌ Failed to get server time: \(error.localizedDescription)")
                        indicator.stopAnimating()
                        okAction.isEnabled = true // allow retry
                    }
                }
            }
        }
        
        okAction = UIAlertAction(title: "OK", style: .default, handler: okHandler)
        alert.addAction(okAction)
        
        // Present alert on main thread
        DispatchQueue.main.async {
            if let topVC = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
                .first {
                topVC.present(alert, animated: true)
            }
        }
    }
}
