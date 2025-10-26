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
    
    func performCheckInOut(isCheckedIn: Bool, workedHours: Double?) {
        var def = UserDefaults.standard.string(forKey: "clockDiffMinutes") ?? "0"
        print("def : \(def)")
        let token = UserDefaults.standard.string(forKey: "employeeToken") ?? ""
        let action = isCheckedIn ? "check_in" : "check_out"

        print("🔘 performCheckInOut called → isCheckedIn=\(isCheckedIn), action=\(action), workedHours=\(String(describing: workedHours))")
        proceedAttendanceAction(action, token: token) { success in
            print(success ? "✅ \(action) completed successfully." : "❌ \(action) failed.")
        }
    }


    private func proceedAttendanceAction(_ action: String, token: String, completion: @escaping (Bool) -> Void) {
        print("📍 Requesting location for action=\(action)")
        locationService.requestLocation { [weak self] coordinate in
            guard let self = self else {
                print("❌ Self deallocated before location callback")
                completion(false)
                return
            }

            guard let coordinate = coordinate else {
                print("❌ Failed to fetch location")
                self.onLocationError?("Unable to fetch location.")
                completion(false)
                return
            }

            let lat = String(UserDefaults.standard.companyLatitude ?? 0)
            let lng = String(UserDefaults.standard.companyLongitude ?? 0)
            print("📍 Got location: lat=\(lat), lng=\(lng)")

            // ✅ Check distance from company location
            if let companyLat = UserDefaults.standard.companyLatitude,
               let companyLng = UserDefaults.standard.companyLongitude,
               let allowed = UserDefaults.standard.allowedDistance {

                let officeLocation = CLLocation(latitude: companyLat, longitude: companyLng)
                let userLocation = CLLocation(latitude: companyLat, longitude: companyLng)
                let distance = userLocation.distance(from: officeLocation)
                print("📏 Distance from office: \(distance) meters (allowed: \(allowed))")

                if distance > allowed {
                    let message = "You cannot perform this action because you are outside the allowed location."
                    print("🚫 User too far from office! Showing alert.")
                    self.onShowAlert?(message, {})
                    completion(false)
                    return
                }
            }

            // ✅ Fetch server time before performing check-in/out
            print("🕒 Fetching server time before sending \(action.uppercased())")

            self.getServerTime(token: token) { result in
                switch result {
                case .success(let serverResponse):
                    guard let serverTime = serverResponse.result?.serverTime,
                          let timezone = serverResponse.result?.timezone else {
                        print("⚠️ Missing server time or timezone in response.")
                        self.onError?("Invalid server time response.")
                        completion(false)
                        return
                    }

                    print("✅ Got server time: \(serverTime) | Timezone: \(timezone)")
                    self.calculateClockDifferenceAndWait {
                        print("new deffrinence : \(UserDefaults.standard.string(forKey: "clockDiffMinutes") ?? "0")" )
                    }
                    self.performAttendanceAction(action: action, token: token, lat: lat, lng: lng, time: serverTime, completion: completion)

                case .failure(let error):
                    print("❌ Failed to get server time: \(error.localizedDescription)")
                   var def = UserDefaults.standard.string(forKey: "clockDiffMinutes") ?? "0"
                    print("def: \(def)")
                    if !NetworkListener.shared.isConnected {
                        if def == "-1000" {
                            self.handleClockTamperingAlertAndRecalculate(action: action)
                            completion(false)
                            return
                        } else {
                            // ✅ Device clock not changed → use saved offset
                            let diffMinutes = UserDefaults.standard.double(forKey: "clockDiffMinutes")
                            let localTimeString = self.getCurrentActionTime() // returns a string like "2025-10-23 12:15:00"

                            // Convert string to Date first
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            formatter.timeZone = TimeZone(abbreviation: "UTC")

                            guard let localNow = formatter.date(from: localTimeString) else {
                                print("❌ Failed to parse local time string: \(localTimeString)")
                                completion(false)
                                return
                            }

                            // Apply saved difference
                            let correctedServerTime = localNow.addingTimeInterval(diffMinutes * 60)
                            let correctedTimeString = formatter.string(from: correctedServerTime)

                            print("""
                            ⚙️ Offline mode:
                            Local time: \(localTimeString)
                            Diff minutes: \(diffMinutes)
                            → Corrected server-equivalent time: \(correctedTimeString)
                            """)

                            self.performAttendanceAction(
                                action: action,
                                token: token,
                                lat: lat,
                                lng: lng,
                                time: correctedTimeString,
                                completion: completion
                            )
                            return
                        }

                    }

                    // ✅ Online but server failed — fallback to UTC local
                    let localTime = self.getCurrentActionTime()
                    print("⚠️ Using local device UTC time instead → \(localTime)")
                    self.performAttendanceAction(action: action, token: token, lat: lat, lng: lng, time: localTime, completion: completion)
                }
            }

        }
    }
    
    private func performAttendanceAction(action: String, token: String, lat: String, lng: String, time: String, completion: @escaping (Bool) -> Void) {
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
        switch result {
        case .success(let response):
            print("✅ Attendance API success: \(response)")
            if response.result?.status == "success" {
                onSuccess?(response)
                completion(true)
            }else {
              //  onError?(response.result?.message ?? "Unknown error")
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
                                self.performCheckInOut(isCheckedIn: action == "check_in", workedHours: nil)
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
