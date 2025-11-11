//
//  SceneDelegate.swift
//  HR
//
//  Created by Esther Elzek on 07/08/2025.
//

import UIKit

    class SceneDelegate: UIResponder, UIWindowSceneDelegate {
        var window: UIWindow?
        
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
            NetworkManager.shared.resendOfflineRequests()
            _ = ClockChangeDetector.shared
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(networkBecameReachable),
                name: .networkReachable,
                object: nil
            )
            if let notificationResponse = connectionOptions.notificationResponse {
                handleNotificationTap(notificationResponse)
            }
           
        }
        
        @objc private func networkBecameReachable() {
            print("🌐 Network became reachable → resending offline requests...")
            NetworkManager.shared.resendOfflineRequests()
        }

        func applicationDidBecomeActive(_ application: UIApplication) {
            print("📱 App became active — trying to resend offline requests...")
            NetworkManager.shared.resendOfflineRequests()
        }

        func sceneDidBecomeActive(_ scene: UIScene) {
            print("📱 App became active — trying to resend offline requests...")
            NetworkManager.shared.resendOfflineRequests()
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
                    print("encryptedText: \(encryptedText)")

                    // Notify your main VC to update or go to login
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name("CompanyFileImported"), object: nil)
                    }

                } catch {
                    print("❌ Failed to import or decrypt file: \(error)")
                }
            }
}

