//
//  NotificationRouter.swift
//  HR
//
//  Created by Esther Elzek on 12/01/2026.
//

import Foundation
import UIKit

final class NotificationRouter {
    static func handle(_ userInfo: [AnyHashable: Any]) {
        print("🔔 Handling notification:", userInfo)

        DispatchQueue.main.async {
            guard
                let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let window = scene.windows.first
            else { return }

            let rootVC = window.rootViewController

            // Example navigation
            if let nav = rootVC as? UINavigationController {
                let vc = NotificationViewController()
                nav.pushViewController(vc, animated: true)
            } else {
                let vc = NotificationViewController()
                window.rootViewController = UINavigationController(rootViewController: vc)
            }
        }
    }
}
