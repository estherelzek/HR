//
//  SplashViewController.swift
//  HR
//
//  Created by Esther Elzek on 22/09/2025.
//

import UIKit
import SwiftGifOrigin

class SplashViewController: UIViewController {
    private let gifImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        view.addSubview(gifImageView)
        
        NSLayoutConstraint.activate([
            gifImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gifImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            gifImageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            gifImageView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        gifImageView.image = UIImage.gif(name: "splash")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            self.showMainApp()
        }
    }
    
    private func showMainApp() {
        if let window = UIApplication.shared.windows.first {
            if let lastVCId = UserDefaults.standard.string(forKey: "LastOpenedVC"),
               let storyboardName = UserDefaults.standard.string(forKey: "LastOpenedStoryboard") {
                let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: lastVCId)
                window.rootViewController = vc
            } else {
                let mainVC = UIStoryboard(name: "Main", bundle: nil)
                    .instantiateViewController(withIdentifier: "ViewController")
                window.rootViewController = mainVC
            }
            
            UIView.transition(with: window,
                              duration: 0.5,
                              options: .transitionCrossDissolve,
                              animations: nil,
                              completion: nil)
        }
    }
}
