//
//  AttendanceViewModel.swift
//  HR
//
//  Created by Esther Elzek on 25/08/2025.
//

import Foundation

final class AttendanceViewModel {
    
    func checkIn(token: String, completion: @escaping (Result<AttendanceResponse, APIError>) -> Void) {
        let endpoint = API.employeeAttendance(action: "check_in", token: token)
        NetworkManager.shared.requestDecodable(endpoint, as: AttendanceResponse.self, completion: completion)
    }
    
    func checkOut(token: String, completion: @escaping (Result<AttendanceResponse, APIError>) -> Void) {
        let endpoint = API.employeeAttendance(action: "check_out", token: token)
        NetworkManager.shared.requestDecodable(endpoint, as: AttendanceResponse.self, completion: completion)
    }
    
    func status(token: String, completion: @escaping (Result<AttendanceResponse, APIError>) -> Void) {
        let endpoint = API.employeeAttendance(action: "status", token: token)
        NetworkManager.shared.requestDecodable(endpoint, as: AttendanceResponse.self, completion: completion)
    }
}
