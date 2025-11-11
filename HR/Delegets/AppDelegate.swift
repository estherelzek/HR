//
//  AppDelegate.swift
//  HR
//
//  Created by Esther Elzek on 07/08/2025.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate , UNUserNotificationCenterDelegate{

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NetworkListener.shared.start()

              NetworkListener.shared.onConnected = {
                  print("🔁 Network is back — resending offline requests...")
                  NetworkManager.shared.resendOfflineRequests()
              }
        _ = ClockChangeDetector.shared
        registerForPushNotifications()
        return true
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
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

func application(_ application: UIApplication,
                 didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let token = deviceToken.map { String(format: "%02x", $0) }.joined()
    print("📱 APNs Token: \(token)")
    // Send this token to your backend API
    sendDeviceTokenToServer(token)
}


  func sendDeviceTokenToServer(_ token: String) {
      guard let baseURL = UserDefaults.standard.baseURL else {
         print("❌ Missing base URL")
          return
    }
      
    // Example endpoint: https://yourapi.com/api/registerDeviceToken
    let url = URL(string: "\(baseURL)/api/registerDeviceToken")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    // Send the token with the user ID or company ID if needed
    let payload: [String: Any] = [
        "deviceToken": token,
        "userId": UserDefaults.standard.employeeToken ?? "",
        "companyId": UserDefaults.standard.string(forKey: "companyIdKey") ?? ""
    ]

    request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("❌ Failed to send device token: \(error)")
            return
        }
        print("✅ Device token sent successfully")
    }.resume()
}

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Failed to register: \(error)")
    }

 func userNotificationCenter(_ center: UNUserNotificationCenter,
                            didReceive response: UNNotificationResponse,
                            withCompletionHandler completionHandler: @escaping () -> Void) {
    print("🔔 Notification tapped: \(response.notification.request.content.userInfo)")
    completionHandler()
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

