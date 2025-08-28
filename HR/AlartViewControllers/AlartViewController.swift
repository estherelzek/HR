//
//  AlartViewController.swift
//  HR
//
//  Created by Esther Elzek on 14/08/2025.
//

import UIKit

class AlartViewController: UIViewController {

    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet var outSideView: UIView!
    @IBOutlet weak var contentView: InspectableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOutsideTap(_:)))
        tapGesture.cancelsTouchesInView = false
        outSideView.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func CloseButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
   
    @IBAction func XButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @objc private func handleOutsideTap(_ gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: contentView)
        if !contentView.bounds.contains(touchPoint) {
            dismiss(animated: true, completion: nil)
        }
    }
}
