//
//  AppDelegate.swift
//  HR
//
//  Created by Esther Elzek on 07/08/2025.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NetworkListener.shared.start()

              NetworkListener.shared.onConnected = {
                  print("🔁 Network is back — resending offline requests...")
                  NetworkManager.shared.resendOfflineRequests()
              }
        _ = ClockChangeDetector.shared

//        if let token = UserDefaults.standard.string(forKey: "employeeToken") {
//            ClockChangeDetector.shared.initializeBaselineIfNeeded(
//                token: token,
//                getServerTime: { token, completion in
//                    AttendanceViewModel().getServerTime(token: token) { result in
//                        completion(result.mapError { $0 as Error })
//                    }
//                }
//            )
//        }

        // ✅ Extra verification when app launches
     //   ClockChangeDetector.shared.verifyClockDifference()

        return true
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
 //       ClockChangeDetector.shared.verifyClockDifference()
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration",
                                    sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration",
                                    sessionRole: connectingSceneSession.role)
    }

  
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    
    }
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    handleImportedFile(url: url)
    return true
}
private func handleImportedFile(url: URL) {
    do {
        let encryptedText = try String(contentsOf: url, encoding: .utf8)
        let middleware = try Middleware.initialize(encryptedText)
        UserDefaults.standard.set(encryptedText, forKey: "encryptedText")
        UserDefaults.standard.set(middleware.companyId, forKey: "companyIdKey")
        UserDefaults.standard.set("HKP0Pt4zTDVf3ZHcGNmM4yx6", forKey: "apiKeyKey")
        UserDefaults.standard.set(middleware.baseUrl, forKey: "baseUrl")
        
        print("✅ Imported CompanyAccess.ihkey successfully")
        print("middleware: \(middleware.companyId) | \(middleware.baseUrl)")
        print("encryptedText: \(encryptedText) ")
        // Optionally navigate to your login view:
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("CompanyFileImported"), object: nil)
        }
        
    } catch {
        print("❌ Failed to import or decrypt file: \(error)")
    }
}

