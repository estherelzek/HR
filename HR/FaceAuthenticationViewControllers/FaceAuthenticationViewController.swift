//
//  FaceAuthenticationViewController.swift
//  HR
//
//  Created by Esther Elzek on 12/10/2025.
//

import UIKit

class FaceAuthenticationViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTexts()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageChanged),
            name: NSNotification.Name("LanguageChanged"),
            object: nil
        )
    }


    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @objc private func languageChanged() { setUpTexts() }
    private func setUpTexts() {
        titleLabel.text = "Use your face ID to continue"
    }
    
}
