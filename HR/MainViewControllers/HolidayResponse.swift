//
//  HolidayResponse.swift
//  HR
//
//  Created by Esther Elzek on 27/08/2025.
//

import Foundation

struct HolidayResponse: Decodable {
    let jsonrpc: String?
    let id: String?
    let result: HolidayResult?
}

struct HolidayResult: Decodable {
    let status: String?
    let working_days: [String: String]?
    let weekly_offs: [String: String]?
    let public_holidays: [PublicHoliday]?
}

struct PublicHoliday: Decodable {
    let name: String
    let start_date: String
    let end_date: String
    let duration: Int
}
