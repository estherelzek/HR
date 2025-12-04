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

    // MARK: - App Launch
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    ) -> Bool {

        // Network listener
        NetworkListener.shared.start()
        NetworkListener.shared.onConnected = {
            print("🔁 Network is back — resending offline requests...")
            NetworkManager.shared.resendOfflineRequests()
        }

        // Clock checker
        _ = ClockChangeDetector.shared

        // Firebase start
        FirebaseApp.configure()

        // Notifications
        UNUserNotificationCenter.current().delegate = self
        requestNotificationAuthorization()
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        
     #if targetEnvironment(simulator)
 DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    Messaging.messaging().token { token, error in
        if let token = token {
            print("🔧 SIMULATOR FCM TOKEN:", token)
            UserDefaults.standard.mobileToken = token
        } else {
            print("❌ SIMULATOR still no FCM token, retrying...")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                Messaging.messaging().token { token, error in
                    print("🔧 Second attempt FCM token:", token ?? "none")
                }
            }
        }
    }
}
        
#endif // targetEnvironment(simulator)
        return true
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("📲 FCM Token:", fcmToken ?? "none")
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
        let userInfo = notification.request.content.userInfo
        print("📩 Notification in foreground:", userInfo)

        completionHandler([.banner, .sound, .badge])
    }

    // MARK: - Handle Notification Tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print("📨 Notification tapped:", userInfo)

        completionHandler()
    }

    // MARK: - Background Push
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {

        let title = userInfo["title"] as? String ?? "New"
        let body = userInfo["body"] as? String ?? "Message"
        saveNotification(title: title, body: body)
        showNotification(title: title, body: body)
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

    // MARK: - Save Notification Locally
    func saveNotification(title: String, body: String) {
        let notification = NotificationModel(
            id: UUID().uuidString,
            title: title,
            message: body,
            date: Date()
        )
        NotificationStore.shared.save(notification)
        print("💾 Saved notification:", title)
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

    private func handleImportedFile(url: URL) {
        do {
            let encryptedText = try String(contentsOf: url, encoding: .utf8)
            let middleware = try Middleware.initialize(encryptedText)

            let defaults = UserDefaults.standard
            defaults.set(encryptedText, forKey: "encryptedText")
            defaults.set(middleware.companyId, forKey: "companyIdKey")
            defaults.set(middleware.apiKey, forKey: "apiKeyKey")  // FIXED
            defaults.set(middleware.baseUrl, forKey: "baseURL")   // FIXED

            print("✅ Imported CompanyAccess.ihkey successfully")

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
