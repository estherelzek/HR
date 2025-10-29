//
//  NetworkListener.swift
//  HR
//
//  Created by Esther Elzek on 01/10/2025.
//

import Network


import Network
import Foundation

import Network

final class NetworkListener {
    static let shared = NetworkListener()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkListener")

    var onConnected: (() -> Void)?
    private(set) var isConnected: Bool = false   // ✅ store connection state

    private init() {}

    func start() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }

            if path.status == .satisfied {
                if !self.isConnected {
                    self.isConnected = true
                    print("🌐 Network connected")
                    self.onConnected?()
                    NotificationCenter.default.post(name: .networkReachable, object: nil) // ✅ notify observers
                }
            } else {
                if self.isConnected {
                    self.isConnected = false
                    print("🚫 Network disconnected")
                }
            }
        }
        monitor.start(queue: queue)
    }

}


//extension NetworkManager {
//    func resendOfflineRequests(token: String? = nil, completion: (() -> Void)? = nil) {
//        let stored = OfflineURLStorage.shared.fetch()
//        guard !stored.isEmpty else {
//            print("📭 No offline requests to resend.")
//            completion?()
//            return
//        }
//
//        print("📡 Attempting to resend \(stored.count) offline requests...")
//
//        var successfullyResent: [OfflineRequest] = []
//        let session = URLSession.shared
//        let dispatchGroup = DispatchGroup()
//        
//        for (index, request) in stored.enumerated() {
//            guard let url = URL(string: request.url) else { continue }
//
//            var urlRequest = URLRequest(url: url)
//            urlRequest.httpMethod = request.method
//            urlRequest.allHTTPHeaderFields = request.headers
//            if let body = request.body {
//                urlRequest.httpBody = body.data(using: .utf8)
//            }
//
//            var actualBody = "nil"
//            if let httpBody = urlRequest.httpBody,
//               let bodyString = String(data: httpBody, encoding: .utf8) {
//                actualBody = bodyString
//            }
//
//            print("""
//                       🚀 Sending offline request \(index + 1)/\(stored.count)
//            ➡️ URL: \(url)
//            ➡️ Method: \(request.method)
//            ➡️ Body: \(actualBody)
//            """)
//
//            dispatchGroup.enter()
//            session.dataTask(with: urlRequest) { data, response, error in
//                defer { dispatchGroup.leave() }
//
//                if let error = error {
//                    print("❌ Network failure for \(url.lastPathComponent): \(error.localizedDescription)")
//                    return
//                }
//
//                guard let httpResponse = response as? HTTPURLResponse else { return }
//                let bodyText = data.flatMap { String(data: $0, encoding: .utf8) } ?? "nil"
//                print("✅ [\(index + 1)/\(stored.count)] \(url.lastPathComponent) → Status: \(httpResponse.statusCode)\n↳ Response: \(bodyText)")
//
//                // ✅ Check both HTTP and logical success
//                if 200...299 ~= httpResponse.statusCode,
//                   let data = data,
//                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
//                   let result = json["result"] as? [String: Any],
//                   let status = result["status"] as? String,
//                   status == "success" {
//                    successfullyResent.append(request)
//                } else {
//                    print("⚠️ Logical failure → request will remain for retry.")
//                }
//            }.resume()
//        }
//
//        dispatchGroup.notify(queue: .main) {
//            if !successfullyResent.isEmpty {
//                OfflineURLStorage.shared.remove(successfullyResent)
//                print("🗑️ Removed \(successfullyResent.count) truly successful requests.")
//            }
//            print("✅ All resend attempts finished.")
//            completion?()
//        }
//    }
//}
extension NetworkManager {
    
    func resendOfflineRequests(token: String? = nil , completion: (() -> Void)? = nil) {
        let viewModel = OfflineAttendanceViewModel()
        var token =  UserDefaults.standard.string(forKey: "employeeToken") ?? ""
        viewModel.sendOfflineLogs(token: token) {
            if let message = viewModel.syncMessage {
                print("📡 Offline sync result: \(message)")
            }
            
            if viewModel.lastSyncedCount > 0 {
                print("🗑️ Removed \(viewModel.lastSyncedCount) offline requests after successful sync.")
            }
            
            completion?()
        }
    }
}
