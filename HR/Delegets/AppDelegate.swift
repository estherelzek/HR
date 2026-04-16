//
//  AppDelegate.swift
//  HR
//
//  Created by Esther Elzek on 07/08/2025.
//

import UIKit
import UserNotifications
import FirebaseCore
import Firebase
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var orientationLock = UIInterfaceOrientationMask.portrait

    // MARK: - App Launch
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    ) -> Bool {
      
        NetworkListener.shared.start()
        NetworkListener.shared.onConnected = {
            print("🔁 Network is back — resending offline requests...")
            NetworkManager.shared.resendOfflineRequests()
        }

        _ = ClockChangeDetector.shared
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        requestNotificationAuthorization()
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        return true
    }
    
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return orientationLock
    }


    func saveNotification(title: String, body: String) {
        let notification = NotificationModel(
            id: UUID().uuidString,
            title: title,
            message: body,
            date: Date()
        )
        NotificationStore.shared.save(notification)
        print("💾 Saved notification:", title)
        NotificationCenter.default.post(name: Notification.Name("NewNotificationSaved"), object: nil)
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("📱 FCM Token:", fcmToken ?? "none")
        UserDefaults.standard.mobileToken = fcmToken
    }

    // MARK: - Request Permission
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("🔔 Notification permission: \(granted)")
        }
    }

    // MARK: - APNs Device Token
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("📱 APNs Device Token:", tokenString)
        Messaging.messaging().apnsToken = deviceToken
        UserDefaults.standard.mobileToken = tokenString
        // Send device token to server
     //   sendDeviceTokenToServer(tokenString)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ Failed to register for notifications:", error)
    }

    // MARK: - Handle Notifications (Foreground)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let content = notification.request.content
        let userInfo = content.userInfo
        
        let title = content.title.isEmpty ? (userInfo["title"] as? String ?? "New") : content.title
        let body = content.body.isEmpty ? (userInfo["body"] as? String ?? "Message") : content.body
        
        print("🟢 ========= PUSH RECEIVED (FOREGROUND) =========")

        if let data = try? JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted),
           let jsonString = String(data: data, encoding: .utf8) {
            print(jsonString)
        }

        if userInfo["aps"] == nil {
            print("❌ PROBLEM: 'aps' key is MISSING → This is DATA-ONLY push.")
        } else {
            print("✅ 'aps' key exists.")
        }

        print("🟢 ==============================================")

   //     saveNotification(title: title, body: body)
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {

        UserDefaults.standard.set(true, forKey: "openedFromNotification")

        NotificationCenter.default.post(
            name: .openNotificationsScreen,
            object: nil,
            userInfo: response.notification.request.content.userInfo
        )

        completionHandler()
    }


    // MARK: - Background Push
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("🟡 ========= PUSH RECEIVED (BACKGROUND) =========")

        if let data = try? JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted),
           let jsonString = String(data: data, encoding: .utf8) {
            print(jsonString)
        }

        if userInfo["aps"] == nil {
            print("❌ PROBLEM: 'aps' key is MISSING → iOS will NOT display notification when app is terminated.")
        } else {
            print("✅ 'aps' key exists.")
        }

        print("🟡 ==============================================")

        let title = userInfo["title"] as? String ?? "New"
        let body = userInfo["body"] as? String ?? "Message"
        saveNotification(title: title, body: body)
       // showNotification(title: title, body: body)
        completionHandler(.newData)
    }

    // MARK: - Show Local Notification
    func showNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }


    // MARK: - File Import Handler
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {

        handleImportedFile(url: url)
        return true
    }

    func handleImportedFile(url: URL) {
            do {
                let encryptedText = try String(contentsOf: url, encoding: .utf8)
                Middleware.reset()
                let middleware = try Middleware.initialize(encryptedText)

                let defaults = UserDefaults.standard
                defaults.set(encryptedText, forKey: "encryptedText")
                defaults.set(middleware.companyId, forKey: "companyIdKey")
                defaults.set(middleware.apiKey, forKey: "apiKeyKey")
                defaults.set(middleware.baseUrl, forKey: "baseURL")
                // 🔥 SET API BASE URL FROM ENCRYPTED FILE
                API.updateDefaultBaseURL(middleware.baseUrl)
                print("✅ Imported CompanyAccess.ihkey successfully")
                print("🔑 API Key: \(middleware.apiKey)")
                print("🏠 Base URL: \(middleware.baseUrl)")
                print("🗯️ Company ID: \(middleware.companyId)")

                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: Notification.Name("CompanyFileImported"),
                        object: nil
                    )
                }

            } catch {
                print("❌ Failed to import or decrypt file:", error)
            }
        }

    // MARK: - Scene Config
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) { }
}
