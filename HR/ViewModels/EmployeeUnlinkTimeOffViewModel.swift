//
//  EmployeeUnlinkTimeOffViewModel.swift
//  HR
//
//  Created by Esther Elzek on 09/09/2025.
//

import Foundation

final class EmployeeUnlinkTimeOffViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var apiMessage: String?
    @Published var success: Bool = false

    func unlinkDraftLeave(token: String, leaveId: Int) {
        isLoading = true
        apiMessage = nil
        success = false

        let endpoint = API.unlinkDraftAnnualLeaves(
            token: token,
            action: "unlink_draft_annual_leaves",
            leaveId: leaveId
        )

        NetworkManager.shared.requestDecodable(endpoint, as: UnlinkDraftLeaveResponse.self) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    if response.result.status == "success" {
                        self?.success = true
                        self?.apiMessage = response.result.message
                        print("✅ Leave Unlinked Successfully: \(response.result.leaveId ?? -1)")
                    } else {
                        self?.success = false
                        self?.apiMessage = response.result.message
                        print("❌ Error: \(response.result.errorCode ?? "UNKNOWN")")
                    }
                case .failure(let error):
                    self?.success = false
                    self?.apiMessage = error.localizedDescription
                    print("🚨 API Failure: \(error.localizedDescription)")
                }
            }
        }
    }
}
