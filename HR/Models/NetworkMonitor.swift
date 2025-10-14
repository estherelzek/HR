//
//  NetworkMonitor.swift
//  HR
//
//  Created by Esther Elzek on 07/10/2025.
//

// File: NetworkMonitor.swift
import Foundation
import Network

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    
    private(set) var isConnected: Bool = false
    private var cachedRequests: [URLRequest] = []
    
    private init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            let wasConnected = self.isConnected
            self.isConnected = path.status == .satisfied
            
            if self.isConnected && !wasConnected {
                print("✅ Internet Restored")
                self.retryCachedRequests()
                NotificationCenter.default.post(name: .networkRestored, object: nil)
            } else if !self.isConnected {
                print("🚫 Internet Lost")
                self.retryCachedRequests()
                NotificationCenter.default.post(name: .networkLost, object: nil)
            }
        }
        monitor.start(queue: queue)
    }
    
    func addRequestToCache(_ request: URLRequest) {
        cachedRequests.append(request)
        print("🗃️ Request cached — total: \(cachedRequests.count)")
    }
    
    private func retryCachedRequests() {
        guard !cachedRequests.isEmpty else { return }
        print("📡 Retrying \(cachedRequests.count) cached requests...")
        
        let session = URLSession.shared
        for req in cachedRequests {
            let task = session.dataTask(with: req) { _, _, error in
                if let error = error {
                    print("⚠️ Retry failed: \(error.localizedDescription)")
                    return
                }
                print("✅ Cached request sent successfully.")
            }
            task.resume()
        }
        cachedRequests.removeAll()
    }
}


