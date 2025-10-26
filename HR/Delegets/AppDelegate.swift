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


