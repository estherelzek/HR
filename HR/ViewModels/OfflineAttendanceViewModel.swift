//
//  OfflineAttendanceViewModel.swift
//  HR
//
//  Created by Esther Elzek on 29/10/2025.
//

import Foundation

final class OfflineAttendanceViewModel: ObservableObject {
    @Published var isSyncing = false
    @Published var syncMessage: String?
    @Published var lastSyncedCount = 0
    
    // MARK: - Send All Offline Logs
    func sendOfflineLogs(token: String, completion: (() -> Void)? = nil) {
        let storedRequests = OfflineURLStorage.shared.fetch()
        guard !storedRequests.isEmpty else {
            syncMessage = "No offline requests to sync."
            print("\(syncMessage ?? "")")
            completion?()
            return
        }
        
      print("storedRequests: \(storedRequests) , count: \(storedRequests.count)")
        let logs: [[String: Any]] = storedRequests.compactMap { request in
            guard
                let body = request.body,
                let data = body.data(using: .utf8),
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let action = json["action"] as? String,
                let lat = json["lat"],
                let lng = json["lng"],
                let actionTime = json["action_time"] as? String
            else { return nil }

            return [
                "action": action,
                "lat": lat,
                "lng": lng,
                "action_time": actionTime,
                "action_tz": "UTC"
            ]
        }

        guard !logs.isEmpty else {
            syncMessage = "No valid offline attendance logs found."
            print("\(String(describing: syncMessage))")
            completion?()
            return
        }

        isSyncing = true
        syncMessage = "Syncing \(logs.count) offline records..."
        print("\(String(describing: syncMessage))")
        print("logs: \(logs), logs.count: \(logs.count)")
        let endpoint = API.offlineAttendance(token: token, attendanceLogs: logs)

        NetworkManager.shared.requestDecodable(endpoint, as: OfflineAttendanceResponse.self) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isSyncing = false

                switch result {
                case .success(let response):
                    print("response esther :\(response)")
                    if response.result?.status.lowercased() == "success" {
                        self.lastSyncedCount = logs.count
                        self.syncMessage = "✅ Successfully synced \(logs.count) logs."
                        print("✅ Successfully synced \(logs.count) logs.")
                        OfflineURLStorage.shared.clear()
                    } else {
                        self.syncMessage = "⚠️ Server error: \(response.result?.message ?? "Unknown")"
                        OfflineURLStorage.shared.clear()
                        let storedRequests = OfflineURLStorage.shared.fetch()
                        print("storedRequests: \(storedRequests) , count: \(storedRequests.count)")
                    }
                case .failure(let error):
                    self.syncMessage = "❌ Sync failed: \(error.localizedDescription)"
                    print("\(String(describing: self.syncMessage))")
                }
                completion?()
            }
        }
    }
}
