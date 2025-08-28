//
//  LanguageManager.swift
//  HR
//
//  Created by Esther Elzek on 18/08/2025.
//

import Foundation
import UIKit

class LanguageManager {
    static let shared = LanguageManager()
    private let appleLanguagesKey = "AppleLanguages"

    func currentLanguage() -> String {
        return UserDefaults.standard.stringArray(forKey: appleLanguagesKey)?.first ?? "en"
    }

    func setLanguage(_ lang: String) {
        UserDefaults.standard.set([lang], forKey: appleLanguagesKey)
        UserDefaults.standard.synchronize()
        Bundle.setLanguage(lang)
        if lang == "ar" {
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        } else {
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
        reloadAllViewControllers()
    }

    private func resetRootViewController() {
        guard let window = UIApplication.shared.windows.first else { return }
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let rootVC = storyboard.instantiateInitialViewController() {
            window.rootViewController = rootVC
            window.makeKeyAndVisible()
            UIView.transition(with: window,
                              duration: 0.4,
                              options: .transitionFlipFromRight,
                              animations: nil,
                              completion: nil)
        }
    }

    private func reloadAllViewControllers() {
        guard let window = UIApplication.shared.windows.first,
              let root = window.rootViewController else { return }
        reloadRecursive(from: root)
    }

    private func reloadRecursive(from vc: UIViewController) {
        if let localizable = vc as? Localizable {
            localizable.reloadTexts()
        }
        if let nav = vc as? UINavigationController {
            nav.viewControllers.forEach { reloadRecursive(from: $0) }
        }
        if let tab = vc as? UITabBarController {
            tab.viewControllers?.forEach { reloadRecursive(from: $0) }
        }

        if let presented = vc.presentedViewController {
            reloadRecursive(from: presented)
        }
        for child in vc.children {
            reloadRecursive(from: child)
        }
    }
}

private var bundleKey: UInt8 = 0
extension Bundle {
    static let once: Void = {
        object_setClass(Bundle.main, PrivateBundle.self)
    }()

    class func setLanguage(_ language: String) {
        Bundle.once
        objc_setAssociatedObject(
            Bundle.main,
            &bundleKey,
            Bundle(path: Bundle.main.path(forResource: language, ofType: "lproj")!),
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }

    private class PrivateBundle: Bundle {
        override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
            if let bundle = objc_getAssociatedObject(self, &bundleKey) as? Bundle {
                return bundle.localizedString(forKey: key, value: value, table: tableName)
            } else {
                return super.localizedString(forKey: key, value: value, table: tableName)
            }
        }
    }
}

protocol Localizable {
    func reloadTexts()
}
