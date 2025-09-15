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
    
    func checkIn(token: String, lat: String, lng: String, completion: @escaping (Result<AttendanceResponse, APIError>) -> Void) {
        print("📤 Sending CHECK-IN request with token=\(token), lat=\(lat), lng=\(lng)")
        let endpoint = API.employeeAttendance(action: "check_in", token: token, lat: "0", lng: "0")
        NetworkManager.shared.requestDecodable(endpoint, as: AttendanceResponse.self, completion: completion)
    }
    
    func checkOut(token: String, lat: String, lng: String, completion: @escaping (Result<AttendanceResponse, APIError>) -> Void) {
        print("📤 Sending CHECK-OUT request with token=\(token), lat=\(lat), lng=\(lng)")
        let endpoint = API.employeeAttendance(action: "check_out", token: token, lat: "30.09891506772385", lng: "31.3375401")
        NetworkManager.shared.requestDecodable(endpoint, as: AttendanceResponse.self, completion: completion)
    }
    
    func status(token: String, completion: @escaping (Result<AttendanceResponse, APIError>) -> Void) {
        print("📤 Sending STATUS request with token=\(token)")
        let endpoint = API.employeeAttendance(action: "status", token: token, lat: nil, lng: nil)
        NetworkManager.shared.requestDecodable(endpoint, as: AttendanceResponse.self, completion: completion)
    }
    
    // MARK: - High-level logic
    func performCheckInOut(isCheckedIn: Bool, workedHours: Double?) {
        let token = UserDefaults.standard.string(forKey: "employeeToken") ?? ""
        let action = isCheckedIn ? "check_out" : "check_in"
        print("🔘 performCheckInOut called")
        print("➡️ Current state: isCheckedIn=\(isCheckedIn), action=\(action), workedHours=\(String(describing: workedHours))")
        
        if action == "check_out" , let workedHours = workedHours , workedHours < 8 {
            print("⚠️ Worked hours < 8, showing alert before checkout")
            onShowAlert?("Worked hours are less than 8. Are you sure you want to check out?") { [weak self] in
                print("✅ User confirmed checkout after alert")
                self?.proceedAttendanceAction(action, token: token)
            }
            print("✅ Proceeding with \(action) directly")
         //   proceedAttendanceAction(action, token: token)
        } else {
            print("✅ Proceeding with \(action) directly")
            proceedAttendanceAction(action, token: token)
        }
//        if action == "check_out", let workedHours = workedHours , workedHours < 8 {
//            print("! worked hours < 8 , show alart before checkout !")
//            onShowAlert?("worked hours are less than 9 . are you sure you want to check out?") {
//                [weak self] in
//                print(" user confirmed checkout after alart !")
//                self?.proceedAttendanceAction(action, token: token)
//            }
//        }
    }
    
    private func proceedAttendanceAction(_ action: String, token: String) {
        print("📍 Requesting location for action=\(action)")
        locationService.requestLocation { [weak self] coordinate in
            guard let self = self else {
                print("❌ Self deallocated before location callback")
                return
            }
            
            guard let coordinate = coordinate else {
                print("❌ Failed to fetch location")
                self.onLocationError?("Unable to fetch location.")
                return
            }
            
            let lat = String(coordinate.latitude)
            let lng = String(coordinate.longitude)
            print("📍 Got location: lat=\(lat), lng=\(lng)")
            // ✅ Fetch company location & allowed distance from UserDefaults
            if let companyLat = UserDefaults.standard.companyLatitude,
               let companyLng = UserDefaults.standard.companyLongitude,
               let allowed = UserDefaults.standard.allowedDistance {
               let officeLocation = CLLocation(latitude: companyLat, longitude: companyLng)
              // let userLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
               let userLocation = CLLocation(latitude: 0, longitude: 0)
               let distance = userLocation.distance(from: officeLocation) // meters
                print("companyLat: \(companyLat), companyLng: \(companyLng)")
                print("userLat: \(coordinate.latitude), userLng: \(coordinate.longitude)")
                print("📏 Distance from office: \(distance) meters, allowed: \(allowed) meters")
                if distance < allowed {
                    // 🚨 User is too far → show alert instead of sending API
                    self.onShowAlert?("You are outside the allowed range (\(Int(distance))m > \(Int(allowed))m).") {
                        print("⚠️ User acknowledged they are far. Not proceeding with request.")
                    }
                    return
                }
            } else {
                print("⚠️ No saved company location/allowed distance found in UserDefaults")
            }
            // ✅ Only reach here if inside allowed distance → call API
            if action == "check_in" {
                print("➡️ Calling checkIn API")
                self.checkIn(token: token, lat: lat, lng: lng, completion: self.handleResult)
            } else {
                print("➡️ Calling checkOut API")
                self.checkOut(token: token, lat: lat, lng: lng, completion: self.handleResult)
            }
        }
    }

    private func handleResult(_ result: Result<AttendanceResponse, APIError>) {
        print("📥 handleResult called with result: \(result)")
        switch result {
        case .success(let response):
            print("✅ Attendance API success: \(response)")
            onSuccess?(response)
        case .failure(let error):
            print("❌ Attendance API failed: \(error.localizedDescription)")
            onError?(error.localizedDescription)
        }
    }
}
