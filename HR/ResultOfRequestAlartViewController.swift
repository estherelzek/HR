//
//  ResultOfRequestAlartViewController.swift
//  HR
//
//  Created by Esther Elzek on 11/08/2025.
//

import UIKit

class ResultOfRequestAlartViewController: UIViewController {

    @IBOutlet weak var tilteLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var requestData: UIStackView!
    @IBOutlet weak var coloredButton: InspectableButton!
    @IBOutlet weak var ActionButton: InspectableButton!
    @IBOutlet weak var contentView: InspectableView!
    @IBOutlet var outSideView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOutsideTap(_:)))
        tapGesture.cancelsTouchesInView = false
        outSideView.addGestureRecognizer(tapGesture)
    }


    @IBAction func ActionButton(_ sender: Any) {
    }
    
    @objc private func handleOutsideTap(_ gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: contentView)
        if !contentView.bounds.contains(touchPoint) {
            dismiss(animated: true, completion: nil)
        }
    }
    
}
