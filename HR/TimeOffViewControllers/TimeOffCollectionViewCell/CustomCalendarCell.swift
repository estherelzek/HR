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
    
    private var circleSize: CGFloat {
        return min(bounds.width, bounds.height) * 0.7
    }
    
    // ✅ Smaller ring size for today indicator so both rings are visible
    private var todayRingSize: CGFloat {
        return min(bounds.width, bounds.height) * 0.88
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customLayer.masksToBounds = false
        contentView.layer.insertSublayer(customLayer, at: 0)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        customLayer.frame = bounds
        customLayer.masksToBounds = false
        contentView.bringSubviewToFront(titleLabel)
    }
    
    // ✅ isToday param added
    func configure(for state: String, color: String? = "", isToday: Bool = false) {
        customLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        titleLabel.textColor = .label
        
        // MARK: - Today ring (drawn first so it appears behind leave shape)
        if isToday {
            let verticalAdjustment: CGFloat = -2
            let center = CGPoint(x: bounds.midX, y: bounds.midY + verticalAdjustment)
            let ringRect = CGRect(
                x: center.x - todayRingSize / 2,
                y: center.y - todayRingSize / 2,
                width: todayRingSize,
                height: todayRingSize
            )
            let todayRing = CAShapeLayer()
            todayRing.path = UIBezierPath(ovalIn: ringRect).cgPath
            todayRing.strokeColor = UIColor.white.cgColor
            todayRing.fillColor = UIColor.clear.cgColor
            todayRing.lineWidth = 2
            customLayer.addSublayer(todayRing)
            
            // ✅ Make title red so today is always obvious
            titleLabel.textColor = .systemRed
        }
        
        // MARK: - Leave state shape (drawn on top of today ring)
        let colorHex = color ?? ""
        guard !colorHex.isEmpty else { return }
        
        let verticalAdjustment: CGFloat = -2
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
            let circle = CAShapeLayer()
            circle.path = circlePath.cgPath
            circle.fillColor = UIColor.fromHex(colorHex).withAlphaComponent(0.2).cgColor
            customLayer.addSublayer(circle)
            
            let hatch = CAShapeLayer()
            let hatchPath = UIBezierPath()
            let spacing: CGFloat = 4
            let extra: CGFloat = circleRect.height * 2
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
