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
        }
//        func sceneDidBecomeActive(_ scene: UIScene) {
//            // Start monitoring the network
//            NetworkListener.shared.start()
//
//            // When the network comes back, automatically resend offline requests
//            NetworkListener.shared.onConnected = {
//                NetworkManager.shared.resendOfflineRequests()
//            }
//        }

        func sceneDidBecomeActive(_ scene: UIScene) {
            print("📱 App became active — trying to resend offline requests...")
            NetworkManager.shared.resendOfflineRequests()
        }

    func sceneDidDisconnect(_ scene: UIScene) {
     
    }

    

    func sceneWillResignActive(_ scene: UIScene) {
    
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
     
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
      
    }
}

