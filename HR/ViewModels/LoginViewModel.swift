//
//  LoginViewModel.swift
//  HR
//
//  Created by Esther Elzek on 24/08/2025.
//

import Foundation
// LoginViewModel.swift


final class LoginViewModel {
    let defaultApiKey   = "Bo5eVrM5gVEgz3C8K8akaBWK"
    let defaultCompanyId = "Com0001"

    func loginTyped(apiKey: String?, companyId: String?, email: String, password: String, completion: @escaping (Result<LoginResponse, APIError>) -> Void) {
        let endpoint = API.validateCompany(
            apiKey: apiKey?.isEmpty == false ? apiKey! : defaultApiKey,
            companyId: companyId?.isEmpty == false ? companyId! : defaultCompanyId,
            email: email,
            password: password
        )
        NetworkManager.shared.requestDecodable(endpoint, as: LoginResponse.self, completion: completion)
    }
    
}
