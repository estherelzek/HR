//
//  APIError.swift
//  HR
//
//  Created by Esther Elzek on 24/08/2025.
//

import Foundation

// MARK: - Structured Error Codes
// Show `displayCode` in the UI so users can report it.
// Each code maps to a precise developer description.
enum AppErrorCode: Int {

    // 1xxx – Network / Connectivity
    case noInternet         = 1001  // Device offline
    case serverUnreachable  = 1002  // Host not reachable
    case requestTimeout     = 1003  // URLSession timed out
    case connectionLost     = 1004  // Connection dropped mid-request
    case dnsLookupFailed    = 1005  // Cannot resolve hostname

    // 2xxx – Server-side HTTP errors
    case serverError        = 2001  // HTTP 500
    case badGateway         = 2002  // HTTP 502
    case serverUnavailable  = 2003  // HTTP 503
    case gatewayTimeout     = 2004  // HTTP 504

    // 3xxx – Client-side HTTP errors
    case badRequest         = 3001  // HTTP 400
    case unauthorized       = 3002  // HTTP 401 – token expired
    case forbidden          = 3003  // HTTP 403
    case notFound           = 3004  // HTTP 404
    case methodNotAllowed   = 3005  // HTTP 405

    // 4xxx – Data / Parsing errors
    case decodingFailed     = 4001  // JSONDecoder failure
    case emptyResponse      = 4002  // nil data from URLSession
    case invalidResponse    = 4003  // Non-HTTP response

    // 5xxx – App-level errors
    case invalidURL         = 5001  // Could not build URLRequest
    case offlineSaved       = 5002  // Request saved for later (no network)

    // 9xxx – Catch-all
    case unknown            = 9999

    // ─── Public Interface ────────────────────────────────────────────────────

    /// The code string to display in the UI, e.g. "ERR-1002"
    var displayCode: String { "ERR-\(rawValue)" }

    /// Short friendly message shown to the end-user
    var userMessage: String {
        switch self {
        case .noInternet:        return NSLocalizedString("error_no_internet", comment: "No internet")
        case .serverUnreachable: return NSLocalizedString("error_server_unreachable", comment: "Server unreachable")
        case .requestTimeout:    return NSLocalizedString("error_timeout", comment: "Timeout")
        case .connectionLost:    return NSLocalizedString("error_connection_lost", comment: "Connection lost")
        case .dnsLookupFailed:   return NSLocalizedString("error_dns", comment: "DNS")
        case .serverError:       return NSLocalizedString("error_server_internal", comment: "500")
        case .badGateway:        return NSLocalizedString("error_bad_gateway", comment: "502")
        case .serverUnavailable: return NSLocalizedString("error_server_unavailable", comment: "503")
        case .gatewayTimeout:    return NSLocalizedString("error_gateway_timeout", comment: "504")
        case .badRequest:        return NSLocalizedString("error_bad_request", comment: "400")
        case .unauthorized:      return NSLocalizedString("error_unauthorized", comment: "401")
        case .forbidden:         return NSLocalizedString("error_forbidden", comment: "403")
        case .notFound:          return NSLocalizedString("error_not_found", comment: "404")
        case .methodNotAllowed:  return NSLocalizedString("error_method_not_allowed", comment: "405")
        case .decodingFailed:    return NSLocalizedString("error_decoding", comment: "Decoding")
        case .emptyResponse:     return NSLocalizedString("error_empty_response", comment: "No data")
        case .invalidResponse:   return NSLocalizedString("error_invalid_response", comment: "Invalid response")
        case .invalidURL:        return NSLocalizedString("error_invalid_url", comment: "Invalid URL")
        case .offlineSaved:      return NSLocalizedString("the_request_saved_locally", comment: "Saved offline")
        case .unknown:           return NSLocalizedString("error_unknown", comment: "Unknown")
        }
    }

    /// Technical description — for developer / support team use
    var debugDescription: String {
        switch self {
        case .noInternet:        return "NSURLErrorNotConnectedToInternet (-1009) – Device has no active internet connection"
        case .serverUnreachable: return "NSURLErrorCannotConnectToHost (-1004) – Server host is unreachable or down"
        case .requestTimeout:    return "NSURLErrorTimedOut (-1001) – URLSession request exceeded the timeout interval"
        case .connectionLost:    return "NSURLErrorNetworkConnectionLost (-1005) – Network dropped mid-request"
        case .dnsLookupFailed:   return "NSURLErrorCannotFindHost (-1003) – DNS lookup failed for baseURL"
        case .serverError:       return "HTTP 500 – Internal server error"
        case .badGateway:        return "HTTP 502 – Bad gateway (proxy/load-balancer issue)"
        case .serverUnavailable: return "HTTP 503 – Service temporarily unavailable / maintenance"
        case .gatewayTimeout:    return "HTTP 504 – Gateway timeout (upstream server too slow)"
        case .badRequest:        return "HTTP 400 – Malformed request or invalid parameters"
        case .unauthorized:      return "HTTP 401 – Authentication required or token expired"
        case .forbidden:         return "HTTP 403 – Authenticated but lacks permission"
        case .notFound:          return "HTTP 404 – Endpoint or resource not found"
        case .methodNotAllowed:  return "HTTP 405 – HTTP method not allowed for this endpoint"
        case .decodingFailed:    return "JSONDecoder failure – response schema does not match model"
        case .emptyResponse:     return "URLSession returned nil data with no error"
        case .invalidResponse:   return "Response is not an HTTPURLResponse"
        case .invalidURL:        return "URLRequest could not be constructed – check baseURL and path"
        case .offlineSaved:      return "No network – request persisted in OfflineURLStorage for later retry"
        case .unknown:           return "Unclassified error – inspect console logs for NSError details"
        }
    }
}

// MARK: - APIError
enum APIError: Error {
    case invalidURL
    case requestFailed(String)
    case decodingError
    case noData
    case unknown
    case coded(AppErrorCode)        // ← carries a precise error code

    // ─── Derived helpers ────────────────────────────────────────────────────

    var errorCode: AppErrorCode {
        switch self {
        case .invalidURL:           return .invalidURL
        case .decodingError:        return .decodingFailed
        case .noData:               return .emptyResponse
        case .unknown:              return .unknown
        case .requestFailed:        return .serverUnreachable
        case .coded(let code):      return code
        }
    }

    /// e.g. "ERR-1002" – show in UI so users can quote it when reporting
    var displayCode: String { errorCode.displayCode }

    /// Friendly sentence for the user
    var userMessage: String { errorCode.userMessage }

    /// Full alert text: message + code
    /// Example: "Cannot reach the server. Please try again later.\n\n(Code: ERR-1002)"
    var alertMessage: String {
        "\(userMessage)\n\n(\(NSLocalizedString("error_code_label", comment: "Error code label")): \(displayCode))"
    }
}

// MARK: - NSURLError → AppErrorCode mapping
extension AppErrorCode {
    /// Map a URLSession NSError to the closest AppErrorCode
    static func from(urlError error: Error) -> AppErrorCode {
        let code = (error as NSError).code
        switch code {
        case NSURLErrorNotConnectedToInternet:  return .noInternet
        case NSURLErrorTimedOut:                return .requestTimeout
        case NSURLErrorCannotConnectToHost,
             NSURLErrorCannotFindHost:          return .serverUnreachable
        case NSURLErrorNetworkConnectionLost:   return .connectionLost
        case NSURLErrorDNSLookupFailed:         return .dnsLookupFailed
        default:                                return .serverUnreachable
        }
    }

    /// Map an HTTP status code to the closest AppErrorCode (nil = success / no mapping needed)
    static func from(httpStatusCode code: Int) -> AppErrorCode? {
        switch code {
        case 200...299: return nil              // success
        case 400:       return .badRequest
        case 401:       return .unauthorized
        case 403:       return .forbidden
        case 404:       return .notFound
        case 405:       return .methodNotAllowed
        case 500:       return .serverError
        case 502:       return .badGateway
        case 503:       return .serverUnavailable
        case 504:       return .gatewayTimeout
        default:        return code >= 500 ? .serverError : .badRequest
        }
    }
}
