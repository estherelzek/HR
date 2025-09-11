//
//  Untitled.swift
//  HR
//
//  Created by Esther Elzek on 07/08/2025.
//

import UIKit

extension UIColor {
    static func fromHex(_ hex: String) -> UIColor {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexFormatted.hasPrefix("#") {
            hexFormatted.remove(at: hexFormatted.startIndex)
        }
        var rgb: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}


extension UIViewController {
    
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true)
    }
    
    func errorMessage(_ error: APIError) -> String {
       switch error {
       case .invalidURL: return "Invalid request URL."
       case .requestFailed(let msg): return msg
       case .decodingError: return "Failed to decode server response."
       case .noData: return "No data from server."
       case .unknown: return "Unknown error occurred."
       }
   }
     func apiWeekday(for date: Date) -> Int {
        let iosWeekday = Calendar.current.component(.weekday, from: date) // 1 = Sunday ... 7 = Saturday
        switch iosWeekday {
        case 1: return 6   // Sunday -> 6
        case 2: return 0   // Monday -> 0
        case 3: return 1   // Tuesday -> 1
        case 4: return 2   // Wednesday -> 2
        case 5: return 3   // Thursday -> 3
        case 6: return 4   // Friday -> 4
        case 7: return 5   // Saturday -> 5
        default: return 0
        }
    }
    
    func goToChecking() {
           let checkingVC = CheckingViewController(nibName: "CheckingViewController", bundle: nil)
           if let rootVC = self.view.window?.rootViewController as? ViewController {
               rootVC.switchTo(viewController: checkingVC)
               rootVC.homeButton.tintColor = .purplecolor
               rootVC.timeOffButton.tintColor = .lightGray
               rootVC.settingButton.tintColor = .lightGray
               rootVC.bottomBarView.isHidden = false
           }
           dismiss(animated: true, completion: nil)
       }
    
    func goToTimeOff() {
           let checkingVC = TimeOffViewController(nibName: "TimeOffViewController", bundle: nil)
           if let rootVC = self.view.window?.rootViewController as? ViewController {
               rootVC.switchTo(viewController: checkingVC)
               rootVC.homeButton.tintColor = .purplecolor
               rootVC.timeOffButton.tintColor = .lightGray
               rootVC.settingButton.tintColor = .lightGray
               rootVC.bottomBarView.isHidden = false
           }
           dismiss(animated: true, completion: nil)
       }
    
    func formatToAPITime(_ timeString: String?) -> String? {
        guard let timeString = timeString else { return nil }
        let allowedChars = CharacterSet(charactersIn: "0123456789:apmAPM").inverted
        var cleanedString = timeString.components(separatedBy: allowedChars).joined()
        cleanedString = cleanedString.lowercased()

        var amPmPart = ""
        if cleanedString.hasSuffix("am") || cleanedString.hasSuffix("pm") {
            let index = cleanedString.index(cleanedString.endIndex, offsetBy: -2)
            amPmPart = String(cleanedString[index...])
            cleanedString = String(cleanedString[..<index])
        }
       
        let timeComponents = cleanedString.components(separatedBy: ":")
        guard timeComponents.count == 2,
              var hour = Int(timeComponents[0]),
              let minute = Int(timeComponents[1]) else {
            return nil
        }
       
        if amPmPart == "pm" && hour != 12 {
            hour += 12
        } else if amPmPart == "am" && hour == 12 {
            hour = 0
        }
      
        let decimalMinutes = Double(minute) / 60.0
        let decimalTime = Double(hour) + decimalMinutes
       
        if decimalTime.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", decimalTime) // no decimals
        } else {
            return String(format: "%.1f", decimalTime) // one decimal
        }
    }

    func showAttentionAlert(
            workedHours: Double?,
            onConfirmAction: (() -> Void)? = nil
        ) {
            let attentionVC = AttentionViewController(nibName: "AttentionViewController", bundle: nil)
            attentionVC.modalPresentationStyle = .overFullScreen
            attentionVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            attentionVC.modalTransitionStyle = .crossDissolve
            attentionVC.workedHoursText = String(format: "%.2f", workedHours ?? 0)
            attentionVC.onConfirm = { [weak self] in
                onConfirmAction?()
            }
        self.present(attentionVC, animated: true, completion: nil)
    }
}

@IBDesignable
class InspectableTextField: UITextField {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet { layer.borderWidth = borderWidth }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet { layer.borderColor = borderColor?.cgColor }
    }
}

@IBDesignable
class InspectableButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        didSet {
            layer.shadowColor = shadowColor?.cgColor
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    
    @IBInspectable var shadowOffset: CGSize = .zero {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
}

@IBDesignable
class InspectableView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        didSet {
            layer.shadowColor = shadowColor?.cgColor
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    
    @IBInspectable var shadowOffset: CGSize = .zero {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
}

extension UIViewController {
    func showToast(message: String, duration: TimeInterval = 5.0) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.font = .systemFont(ofSize: 14)
        toastLabel.textColor = .white
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textAlignment = .center
        toastLabel.numberOfLines = 0
        toastLabel.alpha = 0
        toastLabel.layer.cornerRadius = 12
        toastLabel.clipsToBounds = true
        
        let maxWidthPercentage: CGFloat = 0.8
        let maxTitleSize = CGSize(width: self.view.bounds.size.width * maxWidthPercentage,
                                  height: self.view.bounds.size.height)
        var expectedSize = toastLabel.sizeThatFits(maxTitleSize)
        expectedSize.width += 20
        expectedSize.height += 16
        toastLabel.frame = CGRect(
            x: (self.view.frame.size.width - expectedSize.width) / 2,
            y: self.view.frame.size.height - expectedSize.height - 100,
            width: expectedSize.width,
            height: expectedSize.height
        )
        
        self.view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 0.3, animations: {
            toastLabel.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.3,
                           delay: duration,
                           options: .curveEaseOut,
                           animations: {
                toastLabel.alpha = 0.0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
}
extension TimeOffViewController {
    func color(for state: String) -> UIColor {
        switch state {
        case "confirm":
            return UIColor.fromHex("FAEFE4")
        case "validate1":
            return UIColor.fromHex("DBC4DC")
        case "validate":
            return UIColor.fromHex("C0DFBB")
        case "refuse":
            return UIColor.fromHex("E2BBB9")
        default:
            return .clear
        }
    }

    func datesBetween(start: Date, end: Date) -> [Date] {
        var dates: [Date] = []
        var current = start
        while current <= end {
            dates.append(current)
            guard let next = Calendar.current.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return dates
    }
}

@IBDesignable
class InspectableTableView: UITableView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        didSet {
            layer.shadowColor = shadowColor?.cgColor
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    
    @IBInspectable var shadowOffset: CGSize = .zero {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
}

@IBDesignable
class InspectableCollectionViewCell: UICollectionViewCell {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        didSet {
            layer.shadowColor = shadowColor?.cgColor
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    
    @IBInspectable var shadowOffset: CGSize = .zero {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
}

extension Date {
    func toAPIDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"   // ✅ API requires this
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
    
    static func parseDate(_ text: String) -> Date? {
        let formats = [
            "MMM d, yyyy",   // Sep 7, 2025
            "d MMM yyyy",    // 7 Sep 2025
            "dd/MM/yyyy",    // 07/09/2025
            "MM-dd-yyyy"     // 09-07-2025
        ]
        
        for format in formats {
            let f = DateFormatter()
            f.dateFormat = format
            f.locale = Locale(identifier: "en_US_POSIX")
            if let date = f.date(from: text) {
                return date
            }
        }
        return nil
    }
    func toApiDateString() -> String {
           let formatter = DateFormatter()
           formatter.dateFormat = "yyyy-MM-dd"   // ✅ correct format
           formatter.locale = Locale(identifier: "en_US_POSIX")
           return formatter.string(from: self)
       }
}



extension UserDefaults {
    private enum Keys {
        static let dontShowProtectionScreen = "dontShowProtectionScreen"
        static let employeeToken = "employeeToken"
        static let baseURL = "baseURL"
        static let apiKeyKey = "apiKeyKey"
        static let companyIdKey = "companyIdKey"
        static let companyLatitude = "companyLatitude"
        static let companyLongitude = "companyLongitude"
        static let allowedDistance = "allowedDistance"
    }
    
    var dontShowProtectionScreen: Bool {
        get { bool(forKey: Keys.dontShowProtectionScreen) }
        set { set(newValue, forKey: Keys.dontShowProtectionScreen) }
    }
    
    var employeeToken: String? {
        get { string(forKey: Keys.employeeToken) }
        set { set(newValue, forKey: Keys.employeeToken) }
    }
    
    var baseURL: String? {
        get { string(forKey: Keys.baseURL) }
        set { setValue(newValue, forKey: Keys.baseURL) }
    }
    
    var defaultApiKey: String {
        get { string(forKey: Keys.apiKeyKey) ?? "HKP0Pt4zTDVf3ZHcGNmM4yx6" }
        set { setValue(newValue, forKey: Keys.apiKeyKey) }
    }

    var defaultCompanyId: String {
        get { string(forKey: Keys.companyIdKey) ?? "Com0001" }
        set { setValue(newValue, forKey: Keys.companyIdKey) }
    }
    var companyLatitude: Double? {
        get { object(forKey: Keys.companyLatitude) as? Double }
        set { set(newValue, forKey: Keys.companyLatitude) }
    }

    var companyLongitude: Double? {
        get { object(forKey: Keys.companyLongitude) as? Double }
        set { set(newValue, forKey: Keys.companyLongitude) }
    }

    var allowedDistance: Double? {
        get { object(forKey: Keys.allowedDistance) as? Double }
        set { set(newValue, forKey: Keys.allowedDistance) }
    }

}
