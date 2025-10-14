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
                self.isConnected = true
                print("🌐 Network connected")
                self.onConnected?()
            } else {
                self.isConnected = false
                print("🚫 Network disconnected")
            }
        }
        monitor.start(queue: queue)
    }
}


extension NetworkManager {
    func resendOfflineRequests(token: String? = nil) {
        let stored = OfflineURLStorage.shared.fetch()
        guard !stored.isEmpty else {
            print("📭 No offline requests to resend.")
            return
        }

        print("📡 Attempting to resend \(stored.count) offline requests...")

        for request in stored {
            guard let url = URL(string: request.url) else { continue }

            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = request.method
            urlRequest.allHTTPHeaderFields = request.headers
            if let body = request.body {
                urlRequest.httpBody = body.data(using: .utf8)
            }

            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    print("❌ Failed to resend \(url): \(error.localizedDescription)")
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("✅ Resent \(url) → Status: \(httpResponse.statusCode)")
                    if 200...299 ~= httpResponse.statusCode {
                        OfflineURLStorage.shared.remove([request])
                        print("🗑️ Removed successfully resent request: \(url)")
                    }
                }
            }.resume()
        }
    }
}
