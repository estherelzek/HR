//
//  PinCodeViewController.swift
//  HR
//
//  Created by Esther Elzek on 10/08/2025.
//

import UIKit

class PinCodeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstNum: UITextField!
    @IBOutlet weak var secoundNum: UITextField!
    @IBOutlet weak var thirdNum: UITextField!
    @IBOutlet weak var fouthNum: UITextField!
    @IBOutlet weak var forgetPasswardButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func nextButtonTapped(_ sender: Any) {
        navigateToTimeOffVC()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func forgetpasswordButtonTapped(_ sender: Any) {
    }
    
    func navigateToTimeOffVC() {
        let timeOffVC = TimeOffViewController(nibName: "TimeOffViewController", bundle: nil)
        timeOffVC.modalPresentationStyle = .fullScreen
        present(timeOffVC, animated: true, completion: nil)

    }
}


