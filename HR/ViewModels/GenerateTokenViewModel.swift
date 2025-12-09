//
//  GenerateTokenViewModel.swift
//  HR
//
//  Created by Esther Elzek on 28/10/2025.
//

import Foundation


final class GenerateTokenViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var tokenResponse: TokenRenewalResult?

    // MARK: - Generate Token Function
    func generateNewToken(employeeToken: String, companyId: String, apiKey: String, completion: (() -> Void)? = nil) {
        isLoading = true
        errorMessage = nil

        let endpoint = API.generateToken(
            employee_token: employeeToken,
            company_id: companyId,
            api_key: apiKey
        )

        NetworkManager.shared.requestDecodable(endpoint, as: TokenRenewalResponse.self) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                switch result {
                case .success(let response):
                    print("response of generate token: \(response)")
                    if response.result.status.lowercased() == "success" {
                        self.tokenResponse = response.result
                        // 💾 Optionally save new token
                        UserDefaults.standard.set(response.result.newToken, forKey: "employeeToken")
                        print("✅ Token renewed successfully for \(response.result.employeeName)")
                    } else {
                        self.errorMessage = response.result.message
                        print("⚠️ Server returned: \(response.result.message)")
                    }

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("❌ Token renewal failed:", error)
                }

                completion?()
            }
        }
    }
}
