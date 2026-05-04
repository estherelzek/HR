//
//  LocationUpdateResponse.swift
//  HR
//
//  Created by Esther Elzek on 05/05/2026.
//

import Foundation

// MARK: - Location Update Response (outer wrapper - matches API response structure)
struct LocationUpdateResponse: Decodable {
    let result: LocationUpdateResult?
}

// MARK: - Location Update Result (actual data inside result key)
struct LocationUpdateResult: Decodable {
    let status: String
    let changed: Bool
    let companyLocations: [Company]?
    let allowedLocationsIds: [Int]?

    enum CodingKeys: String, CodingKey {
        case status, changed
        case companyLocations = "company_locations"
        case allowedLocationsIds = "allowed_locations_ids"
    }
}
