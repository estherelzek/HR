//
//  APIError.swift
//  HR
//
//  Created by Esther Elzek on 24/08/2025.
//

import Foundation

// APIError.swift
enum APIError: Error {
    case invalidURL
    case requestFailed(String)
    case decodingError
    case noData
    case unknown
}
