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
    
    // Circle size proportional to cell height, but not too large
    private var circleSize: CGFloat {
        return min(bounds.width, bounds.height) * 0.7 // 90% of the smaller side
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Allow drawing outside label area (fix for clipping)
        customLayer.masksToBounds = false
        contentView.layer.insertSublayer(customLayer, at: 0)
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        customLayer.frame = bounds
        customLayer.masksToBounds = false
    }
    
    func configure(for state: String, color: String? = "") {
        // Clean up old drawings
        customLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        titleLabel.textColor = .label
        
        let colorHex = color ?? ""
        
        // ✅ Draw circle centered relative to the full cell (not titleLabel)
        //    and add small vertical adjustment because FSCalendar’s titleLabel
        //    is slightly lower than center.
        let verticalAdjustment: CGFloat = -2 // move a bit up to appear perfectly centered
        let center = CGPoint(x: bounds.midX, y: bounds.midY + verticalAdjustment)
        
        let circleRect = CGRect(
            x: center.x - circleSize / 2,
            y: center.y - circleSize / 2,
            width: circleSize,
            height: circleSize
        )
        let circlePath = UIBezierPath(ovalIn: circleRect)
        
        switch state {
        case "refuse":
            // Outlined circle with a line
            let outline = CAShapeLayer()
            outline.path = circlePath.cgPath
            outline.strokeColor = UIColor.fromHex(colorHex).cgColor
            outline.fillColor = UIColor.clear.cgColor
            outline.lineWidth = 2
            customLayer.addSublayer(outline)
            
            let linePath = UIBezierPath()
            linePath.move(to: CGPoint(x: circleRect.minX, y: circleRect.midY))
            linePath.addLine(to: CGPoint(x: circleRect.maxX, y: circleRect.midY))
            
            let line = CAShapeLayer()
            line.path = linePath.cgPath
            line.strokeColor = UIColor.fromHex(colorHex).cgColor
            line.lineWidth = 2
            customLayer.addSublayer(line)
            
        case "confirm":
            // Filled circle background
            let circle = CAShapeLayer()
            circle.path = circlePath.cgPath
            circle.fillColor = UIColor.fromHex(colorHex).withAlphaComponent(0.2).cgColor
            customLayer.addSublayer(circle)
            
            // Hatch pattern
            let hatch = CAShapeLayer()
            let hatchPath = UIBezierPath()
            let spacing: CGFloat = 4
            let extra: CGFloat = circleRect.height * 2  // ensure full coverage
            
            // Extend start beyond both sides so lines always cross full circle
            var startX: CGFloat = -extra
            while startX < circleRect.width + extra {
                hatchPath.move(to: CGPoint(x: startX, y: circleRect.minY - extra))
                hatchPath.addLine(to: CGPoint(x: startX + circleRect.height + extra, y: circleRect.maxY + extra))
                startX += spacing
            }
            
            hatch.path = hatchPath.cgPath
            hatch.strokeColor = UIColor.fromHex(colorHex).cgColor
            hatch.lineWidth = 1
            hatch.frame = bounds
            
            // Mask with circle shape to keep lines inside circle
            let mask = CAShapeLayer()
            mask.path = circlePath.cgPath
            hatch.mask = mask
            
            customLayer.addSublayer(hatch)

            
        case "validate":
            let filled = CAShapeLayer()
            filled.path = circlePath.cgPath
            filled.fillColor = UIColor.fromHex(colorHex).cgColor
            customLayer.addSublayer(filled)
            
        default:
            break
        }
    }
}
