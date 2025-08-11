//
//  FingerPrintHandelingManger.swift
//  HR
//
//  Created by Esther Elzek on 10/08/2025.
//

import Foundation
import LocalAuthentication
import UIKit

class FingerPrintHandlingManager {
    
    func authenticate(completion: @escaping (Bool, String?) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to proceed"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                DispatchQueue.main.async {
                    if success {
                        completion(true, nil)
                    } else {
                        completion(false, authError?.localizedDescription)
                    }
                }
            }
        } else {
            completion(false, "Biometric authentication not available.")
        }
    }
}

