//
//  SplashViewController.swift
//  HR
//
//  Created by Esther Elzek on 22/09/2025.
//

import UIKit

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

        // ✅ UIKit-only GIF loading
        gifImageView.image = UIImage.animatedGIF(named: "splash")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            self.showMainApp()
        }
    }

    private func showMainApp() {
        guard let window = UIApplication.shared.windows.first else { return }

        if let lastVCId = UserDefaults.standard.string(forKey: "LastOpenedVC"),
           let storyboardName = UserDefaults.standard.string(forKey: "LastOpenedStoryboard") {

            let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
            window.rootViewController = storyboard.instantiateViewController(withIdentifier: lastVCId)

        } else {
            let mainVC = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "ViewController")
            window.rootViewController = mainVC
        }

        UIView.transition(
            with: window,
            duration: 0.5,
            options: .transitionCrossDissolve,
            animations: nil
        )
    }
}


import UIKit
import ImageIO

extension UIImage {

    static func animatedGIF(named name: String) -> UIImage? {
        guard
            let url = Bundle.main.url(forResource: name, withExtension: "gif"),
            let data = try? Data(contentsOf: url),
            let source = CGImageSourceCreateWithData(data as CFData, nil)
        else { return nil }

        let count = CGImageSourceGetCount(source)
        var images: [UIImage] = []
        var duration: TimeInterval = 0

        for i in 0..<count {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else { continue }

            let frameDuration = UIImage.frameDuration(at: i, source: source)
            duration += frameDuration
            images.append(UIImage(cgImage: cgImage))
        }

        return UIImage.animatedImage(with: images, duration: duration)
    }

    private static func frameDuration(at index: Int, source: CGImageSource) -> TimeInterval {
        guard
            let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
            let gifInfo = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any]
        else { return 0.1 }

        return gifInfo[kCGImagePropertyGIFUnclampedDelayTime] as? TimeInterval
            ?? gifInfo[kCGImagePropertyGIFDelayTime] as? TimeInterval
            ?? 0.1
    }
}
