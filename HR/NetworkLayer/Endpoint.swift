//
//  Endpoint.swift
//  HR
//
//  Created by Esther Elzek on 24/08/2025.
//

import Foundation

//protocol Endpoint {
//    var baseURL: String { get }
//    var path: String { get }
//    var method: HTTPMethod { get }
//    var parameters: [String: Any]? { get }
//    var headers: [String: String]? { get }
//}
//
//extension Endpoint {
//    var urlRequest: URLRequest? {
//        guard let url = URL(string: baseURL + path) else { return nil }
//        var request = URLRequest(url: url)
//        request.httpMethod = method.rawValue
//        request.allHTTPHeaderFields = headers ?? ["Content-Type": "application/json"]
//
//        if let parameters = parameters, method != .GET {
//            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
//        }
//        return request
//    }
//}

protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var body: Data? { get }
}

extension Endpoint {
    var url: URL? {
        return URL(string: baseURL + path)
    }

    var urlRequest: URLRequest? {
        guard let url = url else { return nil }
        var req = URLRequest(url: url)
        req.httpMethod = method.rawValue
        headers.forEach { req.setValue($1, forHTTPHeaderField: $0) }
        req.httpBody = body
        return req
    }
}
