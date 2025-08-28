//
//  AppDelegate.swift
//  HR
//
//  Created by Esther Elzek on 07/08/2025.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

    let lang = LanguageManager.shared.currentLanguage()
    Bundle.setLanguage(lang)

    if lang == "ar" {
       UIView.appearance().semanticContentAttribute = .forceRightToLeft
    } else {
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
    }

    if let lastVCId = UserDefaults.standard.string(forKey: "LastOpenedVC"),
    let storyboardName = UserDefaults.standard.string(forKey: "LastOpenedStoryboard") {
    let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: lastVCId)
    window?.rootViewController = vc
    window?.makeKeyAndVisible()
 }
        
    return true
}
   
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    
    }
}

