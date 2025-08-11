//
//  ViewController.swift
//  HR
//
//  Created by Esther Elzek on 07/08/2025.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var companyInformationTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func scanButtonTapped(_ sender: Any) {
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        let loginVC = LogInViewController(nibName: "LogInViewController", bundle: nil)
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: true, completion: nil)

    }
}
