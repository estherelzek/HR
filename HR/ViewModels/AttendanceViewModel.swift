//
//  AttendanceViewModel.swift
//  HR
//
//  Created by Esther Elzek on 25/08/2025.
//

import Foundation
import CoreLocation

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
        print("isCheckedIn : \(isCheckedIn)")
        let token = UserDefaults.standard.string(forKey: "employeeToken") ?? ""
        let action = isCheckedIn ? "check_in" : "check_out"

        // ✅ Only check for clock change in offline mode
        if !NetworkListener.shared.isConnected {
            if ClockChangeDetector.shared.clockChanged {
                let message = "You’ve changed your device clock. Please reconnect to the internet before proceeding."
                print("🚫 Clock tampering detected — blocking offline action.")
                onShowAlert?(message) {
                    ClockChangeDetector.shared.resetFlag() // optional, reset after user acknowledges
                }
                return
            }
        }

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
                    self.performAttendanceAction(action: action, token: token, lat: lat, lng: lng, time: serverTime, completion: completion)

                case .failure(let error):
                    print("❌ Failed to get server time: \(error.localizedDescription)")

                    // ✅ Only do clock validation when offline
                    if !NetworkListener.shared.isConnected {
                        if ClockChangeDetector.shared.clockChanged {
                            let message = "You’ve changed your device clock. Please reconnect to the internet before proceeding."
                            print("🚫 Clock tampering detected — blocking offline check-in/out.")
                            self.onShowAlert?(message) {
                                ClockChangeDetector.shared.resetFlag()
                            }
                            completion(false)
                            return
                        }
                    }

                    // ✅ If clock is fine, use local time
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

    // MARK: - Result Handling
    private func handleResult(_ result: Result<AttendanceResponse, APIError>, completion: @escaping (Bool) -> Void) {
        switch result {
        case .success(let response):
            print("✅ Attendance API success: \(response)")
            if response.result?.status == "success" {
                onSuccess?(response)
                completion(true)
            }else {
                onError?(response.result?.message ?? "Unknown error")
                completion(false)
            }
         
        case .failure(let error):
            print("❌ Attendance API failed: \(error.localizedDescription)")
            onError?(error.localizedDescription)
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

}
