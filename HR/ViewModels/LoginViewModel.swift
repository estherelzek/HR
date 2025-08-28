//
//  LoginViewModel.swift
//  HR
//
//  Created by Esther Elzek on 24/08/2025.
//

import Foundation

final class LoginViewModel {
     var apiKey: String {
          return UserDefaults.standard.defaultApiKey
      }

       var companyId: String {
          return UserDefaults.standard.defaultCompanyId
      }
 
    var onLoginSuccess: (() -> Void)?
    var onLoginFailure: ((String) -> Void)?

    func loginTyped(apiKey: String?, companyId: String?, email: String, password: String, completion: @escaping (Result<LoginResponse, APIError>) -> Void) {
        let endpoint = API.validateCompany(
            apiKey: apiKey?.isEmpty == false ? apiKey! : UserDefaults.standard.defaultApiKey,
            companyId: companyId?.isEmpty == false ? companyId! : UserDefaults.standard.defaultCompanyId,
            email: email,
            password: password
        )
        NetworkManager.shared.requestDecodable(endpoint, as: LoginResponse.self, completion: completion)
    }

    func login(apiKey: String? = nil, companyId: String? = nil, email: String, password: String) {
        loginTyped(apiKey: apiKey, companyId: companyId, email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    guard let res = response.result else {
                        self.onLoginFailure?(NSLocalizedString("unknown_error", comment: ""))
                        return
                    }

                    if res.status.lowercased() == "error" {
                        let raw = res.message?.textValue ?? NSLocalizedString("unknown_error", comment: "")
                        self.onLoginFailure?(NSLocalizedString(raw, comment: ""))
                        return
                    }
                    if let detail = res.message?.objectValue, detail.status.lowercased() == "error" {
                        self.onLoginFailure?(NSLocalizedString(detail.message, comment: ""))
                        return
                    }
                    if let detail = res.message?.objectValue {
                        if let token = detail.employeeData?.employeeToken {
                            UserDefaults.standard.employeeToken = token
                        }
                    }
                    if let url = res.companyURL {
                        let toSave = url.hasSuffix("/") ? String(url.dropLast()) : url
                        UserDefaults.standard.baseURL = toSave
                    }
                    self.onLoginSuccess?()

                case .failure(let error):
                    self.onLoginFailure?(error.localizedDescription)
                }
            }
        }
    }
}
