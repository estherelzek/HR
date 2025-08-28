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
extension UserDefaults {
    private enum Keys {
        static let dontShowProtectionScreen = "dontShowProtectionScreen"
        static let employeeToken = "employeeToken"
        static let baseURL = "baseURL"
        static let apiKeyKey = "apiKeyKey"
        static let companyIdKey = "companyIdKey"
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
        get { string(forKey: Keys.apiKeyKey) ?? "Bo5eVrM5gVEgz3C8K8akaBWK" }
        set { setValue(newValue, forKey: Keys.apiKeyKey) }
    }

    var defaultCompanyId: String {
        get { string(forKey: Keys.companyIdKey) ?? "Com0001" }
        set { setValue(newValue, forKey: Keys.companyIdKey) }
    }

}
