//
//  ServerTimeResponse.swift
//  HR
//
//  Created by Esther Elzek on 13/10/2025.
//
import Foundation

struct ServerTimeResponse: Codable {
    let jsonrpc: String?
    let id: String?
    let result: ServerTimeResult?
}

struct ServerTimeResult: Codable {
    let status: String
    let message: String
    let serverTime: String
    let timezone: String

    enum CodingKeys: String, CodingKey {
        case status
        case message
        case serverTime = "server_time"
        case timezone
    }
}
