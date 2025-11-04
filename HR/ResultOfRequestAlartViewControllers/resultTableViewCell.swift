//
//  resultTableViewCell.swift
//  HR
//
//  Created by Esther Elzek on 03/11/2025.
//

import UIKit
import Combine

class resultTableViewCell: UITableViewCell {
    @IBOutlet weak var coloredButton: UIButton!
    @IBOutlet weak var numberOfAnnualLeaveLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var ActionButton: InspectableButton!

    private let viewModel = EmployeeUnlinkTimeOffViewModel()
    var leaveId: Int?
    private var cancellables = Set<AnyCancellable>()

    // ✅ Closure callback to notify the ViewController
    var onDeleteTapped: ((Int) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        coloredButton.backgroundColor = .clear
        ActionButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
    }

    @IBAction func ActionButton(_ sender: Any) {
        guard let id = leaveId else { return }
        onDeleteTapped?(id) // 🔥 Notify VC that delete was tapped for this id
    }
}

// MARK: - Shape Drawer for Leave States
extension UIButton {
    func drawLeaveState(_ state: String, colorHex: String = "#B7F73E") {
        // Remove any previous layers
        layer.sublayers?.removeAll(where: { $0.name == "stateShape" })
        
        let circleSize = bounds.height * 0.7
        let circleRect = CGRect(
            x: (bounds.width - circleSize) / 2,
            y: (bounds.height - circleSize) / 2,
            width: circleSize,
            height: circleSize
        )
        let circlePath = UIBezierPath(ovalIn: circleRect)
        let baseColor = UIColor.fromHex(colorHex)
        
        let container = CALayer()
        container.name = "stateShape"
        layer.addSublayer(container)

        switch state {
        case "refuse":
            // Outlined circle with horizontal line
            let outline = CAShapeLayer()
            outline.path = circlePath.cgPath
            outline.strokeColor = baseColor.cgColor
            outline.fillColor = UIColor.clear.cgColor
            outline.lineWidth = 2
            container.addSublayer(outline)
            
            let line = CAShapeLayer()
            let linePath = UIBezierPath()
            linePath.move(to: CGPoint(x: circleRect.minX, y: circleRect.midY))
            linePath.addLine(to: CGPoint(x: circleRect.maxX, y: circleRect.midY))
            line.path = linePath.cgPath
            line.strokeColor = baseColor.cgColor
            line.lineWidth = 2
            container.addSublayer(line)
            
        case "confirm":
            // Hatched fill
            let mask = CAShapeLayer()
            mask.path = circlePath.cgPath
            
            let hatch = CAShapeLayer()
            let hatchPath = UIBezierPath()
            let spacing: CGFloat = 3
            var startX: CGFloat = -circleRect.height
            while startX < circleRect.width {
                hatchPath.move(to: CGPoint(x: startX, y: circleRect.minY))
                hatchPath.addLine(to: CGPoint(x: startX + circleRect.height, y: circleRect.maxY))
                startX += spacing
            }
            hatch.path = hatchPath.cgPath
            hatch.strokeColor = baseColor.withAlphaComponent(0.7).cgColor
            hatch.lineWidth = 1
            hatch.mask = mask
            container.addSublayer(hatch)
            
        case "validate":
            // Solid filled circle
            let circle = CAShapeLayer()
            circle.path = circlePath.cgPath
            circle.fillColor = baseColor.cgColor
            container.addSublayer(circle)
            
        default:
            break
        }
    }
}
