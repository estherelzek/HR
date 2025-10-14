//
//  Attendence.swift
//  HR
//
//  Created by Esther Elzek on 25/08/2025.
//
struct AttendanceResponse: Decodable {
    let result: AttendanceResult?
}

struct AttendanceResult: Decodable {
    let status: String?              // success | error
    let message: String?             // message from API
    let errorCode: String?           // error_code
    let attendanceStatus: String?    // checked_in | checked_out
    let workedHours: Double?
    let checkInTime: String?
    let checkOutTime: String?
    let lastCheckIn: String?
    let lastCheckOut: String?
   

    enum CodingKeys: String, CodingKey {
        case status
        case message
        case errorCode = "error_code"
        case attendanceStatus = "attendance_status"
        case workedHours = "worked_hours"
        case checkInTime = "check_in_time"
        case checkOutTime = "check_out_time"
        case lastCheckIn = "last_check_in"
        case lastCheckOut = "last_check_out"
       
    }
}
