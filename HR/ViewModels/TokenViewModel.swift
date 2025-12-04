//
//  TokenViewModel.swift
//  HR
//
//  Created by Esther Elzek on 02/12/2025.
//

import Foundation

class SendMobileToken {
    
    func sendDeviceTokenToServer(_ deviceToken: String) {
        
        // 1️⃣ Must have employee token
        guard let empToken = UserDefaults.standard.employeeToken else {
            print("❌ No employee token found in UserDefaults")
            return
        }

        // 2️⃣ Build API endpoint
        let endpoint = API.sendMobileToken(
            employeeToken: empToken,
            mobileToken: deviceToken
        )

        // 3️⃣ Make request (decode into MobileTokenResponse)
        NetworkManager.shared.requestDecodable(endpoint, as: MobileTokenResponse.self) { result in
            switch result {
                
            case .success(let response):
                print("✅ Server Response:")
                print("Status: \(response.status)")
                print("Message: \(response.message)")

                if let data = response.data {
                    print("👤 Employee ID: \(data.employeeID)")
                    print("📧 Email: \(data.email)")
                    print("🧑‍💼 Name: \(data.employeeName)")

                    // OPTIONAL: Save to UserDefaults
                    UserDefaults.standard.set(data.employeeID, forKey: "lastEmployeeID")
                    UserDefaults.standard.set(data.email, forKey: "lastEmployeeEmail")
                }

            case .failure(let error):
                print("❌ Failed to send mobile token: \(error)")
            }
        }
    }
}
