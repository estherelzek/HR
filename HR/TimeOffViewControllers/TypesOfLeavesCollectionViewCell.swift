//
//  TypesOfLeavesCollectionViewCell.swift
//  HR
//
//  Created by Esther Elzek on 28/09/2025.
//

import UIKit

class TypesOfLeavesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var coloredButton: InspectableButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    private let customLayer = CALayer()
    private let circleSize: CGFloat = 24  // adjust as needed
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.insertSublayer(customLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        customLayer.frame = bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        customLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        coloredButton.backgroundColor = .clear
        titleLabel.text = nil
    }
    
    func configureState(for state: String) {
        customLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        // Circle rect next to the label
        let circleRect = CGRect(
            x: 4,
            y: (bounds.height - circleSize)/2,
            width: circleSize,
            height: circleSize
        )
        let circlePath = UIBezierPath(ovalIn: circleRect)
        
        switch state {
        case "refuse":
            let outlineLayer = CAShapeLayer()
            outlineLayer.path = circlePath.cgPath
            outlineLayer.strokeColor = UIColor.fromHex("4808C1").cgColor
            outlineLayer.fillColor = UIColor.clear.cgColor
            outlineLayer.lineWidth = 2
            customLayer.addSublayer(outlineLayer)
            
            let linePath = UIBezierPath()
            linePath.move(to: CGPoint(x: circleRect.minX, y: circleRect.midY))
            linePath.addLine(to: CGPoint(x: circleRect.maxX, y: circleRect.midY))
            
            let lineLayer = CAShapeLayer()
            lineLayer.path = linePath.cgPath
            lineLayer.strokeColor = UIColor.fromHex("4808C1").cgColor
            lineLayer.lineWidth = 2
            customLayer.addSublayer(lineLayer)
            
        case "confirm":
            let maskLayer = CAShapeLayer()
            maskLayer.path = circlePath.cgPath
            
            let hatchLayer = CAShapeLayer()
            let hatchPath = UIBezierPath()
            var startX: CGFloat = -circleRect.height
            while startX < circleRect.width {
                hatchPath.move(to: CGPoint(x: startX, y: 0))
                hatchPath.addLine(to: CGPoint(x: startX + circleRect.height, y: circleRect.height))
                startX += 6
            }
            hatchLayer.path = hatchPath.cgPath
            hatchLayer.strokeColor = UIColor.fromHex("4B644A").withAlphaComponent(0.7).cgColor
            hatchLayer.lineWidth = 2
            hatchLayer.frame = bounds
            hatchLayer.mask = maskLayer
            customLayer.addSublayer(hatchLayer)
            
        case "validate":
            let circleLayer = CAShapeLayer()
            circleLayer.path = circlePath.cgPath
            circleLayer.fillColor = UIColor.fromHex("B7F73E").cgColor
            customLayer.addSublayer(circleLayer)
            
        default:
            break
        }
    }
}
