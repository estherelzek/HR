//
//  NetworkManager.swift
//  HR
//
//  Created by Esther Elzek on 24/08/2025.
//

// NetworkManager.swift
import Foundation
struct OfflineRequest: Codable, Equatable {
    let url: String
    let method: String
    let headers: [String: String]
    let body: String?
    let timestamp: Date
}
final class OfflineURLStorage {
    static let shared = OfflineURLStorage()
    private let key = "OfflineFailedRequests"

    private init() {}

    func save(_ request: OfflineRequest) {
        var stored = fetch()
        stored.append(request)
        if let data = try? JSONEncoder().encode(stored) {
            UserDefaults.standard.set(data, forKey: key)
        }
        print("💾 Saved offline request → \(request.url)")
        print("💾 Total offline requests: \(self.fetch().count)")
        print("body of request: \(String(describing: request.body))")
    }

    func fetch() -> [OfflineRequest] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let stored = try? JSONDecoder().decode([OfflineRequest].self, from: data)
        else { return [] }
        return stored
    }

    func remove(_ requests: [OfflineRequest]) {
        var stored = fetch()
        stored.removeAll { requests.contains($0) }
        if let data = try? JSONEncoder().encode(stored) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    // MARK: - Decodable Request
    func requestDecodable<T: Decodable>(
        _ endpoint: Endpoint,
        as type: T.Type,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        guard let request = endpoint.urlRequest else {
            completion(.failure(.invalidURL))
            return
        }

        print("🌍 [API REQUEST]")
        print("➡️ URL: \(request.url?.absoluteString ?? "nil")")
        print("➡️ Method: \(request.httpMethod ?? "nil")")
        print("➡️ Headers: \(request.allHTTPHeaderFields ?? [:])")

        if let body = request.httpBody,
           let jsonString = String(data: body, encoding: .utf8) {
            print("➡️ Body: \(jsonString)")
        } else {
            print("➡️ Body: nil")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")

                // ⬇️ Save the failed request locally
                let offlineRequest = OfflineRequest(
                    url: request.url?.absoluteString ?? "",
                    method: request.httpMethod ?? "GET",
                    headers: request.allHTTPHeaderFields ?? [:],
                    body: request.httpBody.flatMap { String(data: $0, encoding: .utf8) },
                    timestamp: Date()
                )
                OfflineURLStorage.shared.save(offlineRequest)

                completion(.failure(.requestFailed(error.localizedDescription)))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("✅ [API RESPONSE] Status Code: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            // 🪶 Print Raw Response Data (as JSON or string)
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 [RAW RESPONSE DATA]:\n\(jsonString)")
            } else {
                print("📦 [RAW RESPONSE DATA]: <non-UTF8 binary data>")
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
