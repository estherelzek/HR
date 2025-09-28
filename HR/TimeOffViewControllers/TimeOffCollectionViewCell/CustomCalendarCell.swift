//
//  CustomCalendarCell.swift
//  HR
//
//  Created by Esther Elzek on 24/09/2025.
//

import Foundation
import FSCalendar

class TimeOffCalendarCell: FSCalendarCell {
    
    private let customLayer = CALayer()
    private let circleSize: CGFloat = 34  // adjust to match the circle diameter
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.insertSublayer(customLayer, at: 0) // behind day label
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        customLayer.frame = bounds
    }
    
    func configure(for state: String) {
        customLayer.sublayers?.forEach { $0.removeFromSuperlayer() } // clear old drawings
        
        // Make a circle centered on the title label
        let center = titleLabel.center
        let circleRect = CGRect(
            x: center.x - circleSize/2,
            y: center.y - circleSize/2,
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
            
            let spacing: CGFloat = 8
            var startX: CGFloat = -circleRect.height
            while startX < circleRect.width {
                hatchPath.move(to: CGPoint(x: startX , y: 0))
                hatchPath.addLine(to: CGPoint(x: startX + circleRect.height, y: circleRect.height))
                startX += spacing
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
