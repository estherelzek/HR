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
    private var circleSize: CGFloat {
        return bounds.height * 0.7
    }
    
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
        
        let circleRect = CGRect(
            x: 4,
            y: (bounds.height - circleSize) / 2,
            width: circleSize,
            height: circleSize
        )
        let circlePath = UIBezierPath(ovalIn: circleRect)
        
        switch state {
        case "refuse":
            // Outlined circle with a horizontal line
            let outlineLayer = CAShapeLayer()
            outlineLayer.path = circlePath.cgPath
            outlineLayer.strokeColor = UIColor.fromHex("B7F73E").cgColor
            outlineLayer.fillColor = UIColor.clear.cgColor
            outlineLayer.lineWidth = 2
            customLayer.addSublayer(outlineLayer)
            
            let linePath = UIBezierPath()
            linePath.move(to: CGPoint(x: circleRect.minX, y: circleRect.midY))
            linePath.addLine(to: CGPoint(x: circleRect.maxX, y: circleRect.midY))
            
            let lineLayer = CAShapeLayer()
            lineLayer.path = linePath.cgPath
            lineLayer.strokeColor = UIColor.fromHex("B7F73E").cgColor
            lineLayer.lineWidth = 2
            customLayer.addSublayer(lineLayer)
            
        case "confirm":
            let maskLayer = CAShapeLayer()
            maskLayer.path = circlePath.cgPath
            let hatchLayer = CAShapeLayer()
            let hatchPath = UIBezierPath()
            let spacing: CGFloat = 5
            var startX: CGFloat = -circleRect.height
            
            while startX < circleRect.width {
                hatchPath.move(to: CGPoint(x: startX, y: circleRect.minY))
                hatchPath.addLine(to: CGPoint(x: startX + circleRect.height, y: circleRect.maxY))
                startX += spacing
            }
            hatchLayer.path = hatchPath.cgPath
            hatchLayer.strokeColor = UIColor.fromHex("B7F73E").withAlphaComponent(0.7).cgColor
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
