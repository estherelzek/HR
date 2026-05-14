//
//  SceneDelegate.swift
//  HR
//
//  Created by Esther Elzek on 07/08/2025.
//

import UIKit
import UserNotifications

    class SceneDelegate: UIResponder, UIWindowSceneDelegate {
        var window: UIWindow?
        private var didCheckForUpdateThisSession = false
        private var isPresentingUpdateAlert = false
        
        func scene(_ scene: UIScene,
                   willConnectTo session: UISceneSession,
                   options connectionOptions: UIScene.ConnectionOptions) {
            
            guard let windowScene = (scene as? UIWindowScene) else { return }
            let window = UIWindow(windowScene: windowScene)
            
            let isDarkModeEnabled = UserDefaults.standard.bool(forKey: "isDarkModeEnabled")
            window.overrideUserInterfaceStyle = isDarkModeEnabled ? .dark : .dark
            if let window = UIApplication.shared.windows.first {
                window.overrideUserInterfaceStyle = true ? .dark : .dark
            }
            UserDefaults.standard.set(true, forKey: "isDarkModeEnabled")
            UserDefaults.standard.synchronize()
            let splashVC = SplashViewController(nibName: "SplashViewController", bundle: nil)
            window.rootViewController = splashVC
            self.window = window
            window.makeKeyAndVisible()
            NetworkListener.shared.start()

                  NetworkListener.shared.onConnected = {
                     print("🔁 Network is back — resending offline requests...")
                    NetworkManager.shared.resendOfflineRequests()
                  }
            print("🔁 bbbb Network is back — resending offline requests...")
         //   NetworkManager.shared.resendOfflineRequests()
            _ = ClockChangeDetector.shared
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(networkBecameReachable),
                name: .networkReachable,
                object: nil
            )
            if let response = connectionOptions.notificationResponse {
                UserDefaults.standard.set(true, forKey: "openedFromNotification")

             
                NotificationCenter.default.post(
                    name: .openNotificationsScreen,
                    object: nil,
                    userInfo: response.notification.request.content.userInfo
                )
            }

//            do {
//                let encryptedText = "SC8AOBx7JpINf6WpTJ8SvJFkugw+7IYRHzpd5CEDYAYvwuEi3tcQO/hslgmsHT+lHyEKOWJvqnm9PT1TPkoXD317b5+Hp5YUuUto3BNMgzxVPRKna41rQaGExYaRfnao"
//                let middleware = try Middleware.initialize(encryptedText)
//
//                let defaults = UserDefaults.standard
//                defaults.set(encryptedText, forKey: "encryptedText")
//                defaults.set(middleware.companyId, forKey: "companyIdKey")
//                defaults.set(middleware.apiKey, forKey: "apiKeyKey")  // FIXED
//                defaults.set(middleware.baseUrl, forKey: "baseURL")   // FIXED
//
//                print("✅ Imported CompanyAccess.ihkey successfully")
//                print("🔑 API Key: \(middleware.apiKey)")
//                print("🏠 Base URL: \(middleware.baseUrl)")
//                print("🗯️ Company ID: \(middleware.companyId)")
//                DispatchQueue.main.async {
//                    NotificationCenter.default.post(
//                        name: Notification.Name("CompanyFileImported"),
//                        object: nil
//                    )
//                }
//
//            } catch {
//                print("❌ Failed to import or decrypt file:", error)
//            }
        }
        
        @objc private func networkBecameReachable() {
            print("🌐 Network became reachable → resending offline requests...")
            NetworkManager.shared.resendOfflineRequests()
        }

        func applicationDidBecomeActive(_ application: UIApplication) {
            print("📱 App became active — trying to resend offline requests...")
         //   NetworkManager.shared.resendOfflineRequests()
        }

        func sceneDidBecomeActive(_ scene: UIScene) {
            print("📱 App became active — trying to resend offline requests...")
       //    NetworkManager.shared.resendOfflineRequests()
            UIApplication.shared.applicationIconBadgeNumber = 0
            checkForAppStoreUpdateIfNeeded()
        }

        func sceneDidDisconnect(_ scene: UIScene) {
            
        }

        private func handleNotificationTap(_ response: UNNotificationResponse) {
            print("🔔 User tapped notification: \(response.notification.request.content.userInfo)")
            // Example: navigate to a specific view controller
        }


    func sceneWillResignActive(_ scene: UIScene) {
    
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
     
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
      
    }
        func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
                guard let url = URLContexts.first?.url else { return }
                handleImportedFile(url: url)
            }

        func handleImportedFile(url: URL) {
                do {
                    let encryptedText = try String(contentsOf: url, encoding: .utf8)

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

        private func checkForAppStoreUpdateIfNeeded() {
            guard !didCheckForUpdateThisSession else { return }
            didCheckForUpdateThisSession = true

            AppStoreUpdateChecker.shared.checkForUpdate { [weak self] result in
                switch result {
                case .success(let updateInfo):
                    guard let self, let updateInfo else { return }
                    DispatchQueue.main.async {
                        self.presentUpdateAlertWhenReady(with: updateInfo, retryCount: 0)
                    }
                case .failure(let error):
                    print("⚠️ Failed to check App Store version: \(error.localizedDescription)")
                }
            }
        }

        private func presentUpdateAlertWhenReady(with updateInfo: AppStoreUpdateInfo, retryCount: Int) {
            guard !isPresentingUpdateAlert else { return }

            let topController = topViewController(from: window?.rootViewController)

            if topController is SplashViewController || topController == nil {
                guard retryCount < 8 else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.presentUpdateAlertWhenReady(with: updateInfo, retryCount: retryCount + 1)
                }
                return
            }

            isPresentingUpdateAlert = true
            let message = "A new version (\(updateInfo.appStoreVersion)) is available on the App Store."
            let alert = UIAlertController(title: "Update Available", message: message, preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Later", style: .cancel, handler: { [weak self] _ in
                self?.isPresentingUpdateAlert = false
            }))

            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { [weak self] _ in
                self?.isPresentingUpdateAlert = false
                UIApplication.shared.open(updateInfo.appStoreURL, options: [:], completionHandler: nil)
            }))

            topController?.present(alert, animated: true)
        }

        private func topViewController(from root: UIViewController?) -> UIViewController? {
            if let navigationController = root as? UINavigationController {
                return topViewController(from: navigationController.visibleViewController)
            }
            if let tabBarController = root as? UITabBarController {
                return topViewController(from: tabBarController.selectedViewController)
            }
            if let presentedViewController = root?.presentedViewController {
                return topViewController(from: presentedViewController)
            }
            return root
        }
}

