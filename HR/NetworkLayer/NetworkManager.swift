//
//  NetworkManager.swift
//  HR
//
//  Created by Esther Elzek on 24/08/2025.
//

// NetworkManager.swift
import Foundation

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    // MARK: - Decodable Request
    func requestDecodable<T: Decodable>(_ endpoint: Endpoint, as type: T.Type, completion: @escaping (Result<T, APIError>) -> Void) {
        guard let request = endpoint.urlRequest else {
            completion(.failure(.invalidURL))
            return
        }

        // 🔹 Debug Print Request Info
        print("🌍 [API REQUEST]")
        print("➡️ URL: \(request.url?.absoluteString ?? "nil")")
        print("➡️ Method: \(request.httpMethod ?? "nil")")
        print("➡️ Headers: \(request.allHTTPHeaderFields ?? [:])")

        if let body = request.httpBody,
           let jsonString = String(data: body, encoding: .utf8) {
            print("➡️ Body: \(jsonString)")   // ✅ Now prints valid JSON
        } else {
            print("➡️ Body: nil")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed(error.localizedDescription)))
                return
            }

            // 🔹 Debug Print Response Info
            if let httpResponse = response as? HTTPURLResponse {
                print("✅ [API RESPONSE] Status Code: \(httpResponse.statusCode)")
            }

            if let data = data,
               let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Raw Response: \(jsonString)")
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                print("❌ Decoding Error: \(error)")
                completion(.failure(.decodingError))
            }
        }.resume()
    }

}
