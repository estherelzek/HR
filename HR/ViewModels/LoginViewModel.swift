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

                    // Check if top-level result status is error
                    if res.status.lowercased() == "error" {
                        let raw = res.message?.textValue ?? NSLocalizedString("unknown_error", comment: "")
                        self.onLoginFailure?(NSLocalizedString(raw, comment: ""))
                        return
                    }

                    // Check if message object has error
                    if let detail = res.message?.objectValue, detail.status.lowercased() == "error" {
                        self.onLoginFailure?(NSLocalizedString(detail.message, comment: ""))
                        return
                    }

                    // Safely unwrap message object
                    guard let detail = res.message?.objectValue else {
                        self.onLoginFailure?(NSLocalizedString("unknown_error", comment: ""))
                        return
                    }

                    // 1️⃣ Save employee token
                    if let token = detail.employeeData?.employeeData.employeeToken {
                        UserDefaults.standard.employeeToken = token
                    }
                    // 1️⃣ Save employee token
                    if let name = detail.employeeData?.employeeData.name {
                        UserDefaults.standard.employeeName = name
                    }
                    // 1️⃣ Save employee token
                    if let email = detail.employeeData?.employeeData.email {
                        UserDefaults.standard.employeeEmail = email
                    }

                    // 2️⃣ Save company base URL
                    if let url = res.companyURL {
                        let base = url.hasSuffix("/") ? String(url.dropLast()) : url
                       // UserDefaults.standard.defaultURL = UserDefaults.standard.baseURL
                        UserDefaults.standard.baseURL = base
                    }

                    // 3️⃣ Save company branches
                    if let companies = detail.company {
                        let branches: [AllowedLocation] = companies.compactMap { comp in
                            guard let addr = comp.address,
                                  let id = addr.id,
                                  let lat = addr.latitude,
                                  let lng = addr.longitude,
                                  let allowed = addr.allowedDistance else { return nil }
                            return AllowedLocation(id: id, latitude: lat, longitude: lng, allowedDistance: allowed)
                        }

                        if let encoded = try? JSONEncoder().encode(branches) {
                            UserDefaults.standard.set(encoded, forKey: "companyBranches")
                        }
                        print("🏢 Saved company branches: \(branches.map { $0.id })")

                        if let allowedIDs = detail.employeeData?.employeeData.allowedLocationIDs {
                            UserDefaults.standard.allowedBranchIDs = allowedIDs
                            print("🟦 Employee allowed branches: \(allowedIDs)")
                        }
                    }

                    print("UserDefaults.standard.companyLatitude: \(UserDefaults.standard.companyLatitude ?? 0.0)")
                    print("UserDefaults.standard.companyLongitude: \(UserDefaults.standard.companyLongitude ?? 0.0)")

                    // Call success callback
                    self.onLoginSuccess?()

                    // Send FCM token if available
                    if let fcmToken = UserDefaults.standard.mobileToken {
                        print("📱 FCM Token:\(fcmToken)")
                        SendMobileToken().sendDeviceTokenToServer(fcmToken)
                    }

                case .failure(let error):
                    self.onLoginFailure?("Weak Network Connection. Please try againnnn.")
                }
            }
        }
    }

}
