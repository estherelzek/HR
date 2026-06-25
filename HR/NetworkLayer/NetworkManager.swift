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
    let actionType: String? // "check_in" or "check_out"
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
    
    func isTimeSetAutomatically() -> Bool {
        #if targetEnvironment(simulator)
        // Simulator cannot read system time preferences — always assume automatic
        print("⚠️ Running on Simulator — assuming time is set automatically")
        return true
        #else
        guard let automatic = CFPreferencesCopyAppValue(
            "TMAutomaticTimeEnabled" as CFString,
            "com.apple.preferences.datetime" as CFString
        ) as? Bool else {
           print("If we can't read it, assume false (manual)")
            return false
        }
        return automatic
        #endif
    }
}

final class RequestCounter {
    static let shared = RequestCounter()

    private let key = "TotalSentRequestsCount"
    private let queue = DispatchQueue(label: "com.hr.requestCounter")

    private init() {}

    var total: Int {
        queue.sync {
            UserDefaults.standard.integer(forKey: key)
        }
    }

    @discardableResult
    func increment() -> Int {
        queue.sync {
            let next = UserDefaults.standard.integer(forKey: key) + 1
            UserDefaults.standard.set(next, forKey: key)
            return next
        }
    }

    func reset() {
        queue.sync {
            UserDefaults.standard.set(0, forKey: key)
        }
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
        let requestNumber = RequestCounter.shared.increment()
        print("📊 Request Number: #\(requestNumber)")
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
                // ── Map NSURLError → structured AppErrorCode ──────────────
                let appCode = AppErrorCode.from(urlError: error)
                print("❌ Network error [\(appCode.displayCode)] \(appCode.debugDescription)")
                print("   NSError: \(error.localizedDescription)")

                // ✅ Save offline for attendance actions
                let offlineRequest = OfflineRequest(
                    url: request.url?.absoluteString ?? "",
                    method: request.httpMethod ?? "POST",
                    headers: request.allHTTPHeaderFields ?? [:],
                    body: request.httpBody.flatMap { String(data: $0, encoding: .utf8) },
                    timestamp: Date(),
                    actionType: endpoint.actionType
                )
                print("endpoint.actionType: \(String(describing: endpoint.actionType))")
                print("offlineRequest: \(offlineRequest)")
                OfflineURLStorage.shared.save(offlineRequest)

                completion(.failure(.coded(appCode)))
                return
            }

            // ── Validate HTTP status code ──────────────────────────────────
            if let httpResponse = response as? HTTPURLResponse {
                print("✅ [API RESPONSE] Status Code: \(httpResponse.statusCode)")
                if let httpErrorCode = AppErrorCode.from(httpStatusCode: httpResponse.statusCode) {
                    print("❌ HTTP error [\(httpErrorCode.displayCode)] \(httpErrorCode.debugDescription)")
                    completion(.failure(.coded(httpErrorCode)))
                    return
                }
            } else if response != nil {
                let code = AppErrorCode.invalidResponse
                print("❌ [\(code.displayCode)] \(code.debugDescription)")
                completion(.failure(.coded(code)))
                return
            }

            guard let data = data else {
                let code = AppErrorCode.emptyResponse
                print("❌ [\(code.displayCode)] \(code.debugDescription)")
                completion(.failure(.coded(code)))
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
                let code = AppErrorCode.decodingFailed
                print("❌ [\(code.displayCode)] \(code.debugDescription)")
                print("   Swift error: \(error)")
                completion(.failure(.coded(code)))
            }
        }.resume()
    }

    // MARK: - Multipart Upload Request
    func uploadMultipart<T: Decodable>(
        url: URL,
        params: [String: Any],
        fileData: Data?,
        fileName: String?,
        fileMimeType: String?,
        fileFieldName: String = "attachment",
        as type: T.Type,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        let boundary = "Boundary-\(UUID().uuidString)"

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Add JSON params as individual form fields
        func appendField(name: String, value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        // Flatten params to form fields
        for (key, value) in params {
            if let dict = value as? [String: Any],
               let jsonData = try? JSONSerialization.data(withJSONObject: dict),
               let jsonStr = String(data: jsonData, encoding: .utf8) {
                appendField(name: key, value: jsonStr)
            } else if let array = value as? [Any],
                      let jsonData = try? JSONSerialization.data(withJSONObject: array),
                      let jsonStr = String(data: jsonData, encoding: .utf8) {
                appendField(name: key, value: jsonStr)
            } else {
                appendField(name: key, value: "\(value)")
            }
        }

        // Add file if present
        if let fileData = fileData,
           let fileName = fileName,
           let mimeType = fileMimeType {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(fileFieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
            body.append(fileData)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        print("🌍 [MULTIPART UPLOAD]")
        let requestNumber = RequestCounter.shared.increment()
        print("📊 Request Number: #\(requestNumber)")
        print("➡️ URL: \(url.absoluteString)")
        print("➡️ File: \(fileName ?? "none") (\(fileData?.count ?? 0) bytes)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Upload error: \(error.localizedDescription)")
                completion(.failure(.requestFailed(error.localizedDescription)))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("✅ [UPLOAD RESPONSE] Status Code: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 [UPLOAD RESPONSE DATA]:\n\(jsonString)")
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                print("❌ Upload Decoding Error: \(error)")
                completion(.failure(.decodingError))
            }
        }.resume()
    }
}
