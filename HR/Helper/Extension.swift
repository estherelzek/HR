//
//  Untitled.swift
//  HR
//
//  Created by Esther Elzek on 07/08/2025.
//

import UIKit


extension UIImage {
    static func fromBase64(_ base64: String) -> UIImage? {
        guard let data = Data(base64Encoded: base64, options: .ignoreUnknownCharacters) else {
            print("Failed to create Data from Base64 string")
            return nil
        }
        guard let image = UIImage(data: data) else {
            print("Data created but failed to make UIImage")
            return nil
        }
        return image
    }
}


extension Notification.Name {
    static let openNotificationsScreen = Notification.Name("openNotificationsScreen")
}

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
extension UICollectionView {

    @IBInspectable
    var borderWidth: CGFloat {
        get { layer.borderWidth }
        set { layer.borderWidth = newValue }
    }

    @IBInspectable
    var borderColor: UIColor? {
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

extension String {
    func formattedHour(using leaveDay: String) -> String {
        let components = self.split(separator: ".")
        let hour = Int(components[0]) ?? 0
        let minutes = components.count > 1 ? Int(Double("0.\(components[1])")! * 60) : 0
        
        var dateComponents = DateComponents()
        dateComponents.year = Int(leaveDay.prefix(4))
        dateComponents.month = Int(leaveDay.dropFirst(5).prefix(2))
        dateComponents.day = Int(leaveDay.suffix(2))
        dateComponents.hour = hour
        dateComponents.minute = minutes
        
        let calendar = Calendar.current
        guard let date = calendar.date(from: dateComponents) else { return self }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a" // 12-hour clock
        return formatter.string(from: date)
    }
}


extension UIViewController {
    
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok_button", comment: ""), style: .default, handler: { _ in
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
           let checkingVC = CheckingVC(nibName: "CheckingVC", bundle: nil)
           if let rootVC = self.view.window?.rootViewController as? ViewController {
               rootVC.switchTo(viewController: checkingVC)
               rootVC.homeButton.tintColor = .purplecolor
               rootVC.timeOffButton.tintColor = .lightGray
               rootVC.settingButton.tintColor = .lightGray
               rootVC.bottomBarView.isHidden = false
               rootVC.titlesBarView.isHidden = false
           }
           dismiss(animated: true, completion: nil)
       }
    
     func goToCheckingVC() {
        if let rootVC = self.view.window?.rootViewController as? ViewController {
            let checkVC = CheckingVC(nibName: "CheckingVC", bundle: nil)
            rootVC.switchTo(viewController: checkVC)
            rootVC.bottomBarView.isHidden = false
            rootVC.titlesBarView.isHidden = false
            rootVC.homeButton.tintColor = .purplecolor
            rootVC.timeOffButton.tintColor = .lightGray
            rootVC.settingButton.tintColor = .lightGray
        }
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }

    func goToScanVC() {
//        if let appDomain = Bundle.main.bundleIdentifier {
//            UserDefaults.standard.removePersistentDomain(forName: appDomain)
//        }
        UserDefaults.standard.removeObject(forKey: "encryptedText")
        if let window = UIApplication.shared.windows.first {
            window.overrideUserInterfaceStyle = .dark
        }
        UserDefaults.standard.set(true, forKey: "isDarkModeEnabled")
        UserDefaults.standard.synchronize()
        let currectMode = UserDefaults.standard.object(forKey: "isDarkModeEnabled")
        print("currectMode: \(String(describing: currectMode))") // will be false
    
        let checkingVC = ScanAndInfoViewController(nibName: "ScanAndInfoViewController", bundle: nil)
        if let rootVC = self.view.window?.rootViewController as? ViewController {
            rootVC.switchTo(viewController: checkingVC)
            rootVC.bottomBarView.isHidden = true
            rootVC.titlesBarView.isHidden = true
        }
    }

    func goToLogInViewController() {
           let checkingVC = LogInViewController(nibName: "LogInViewController", bundle: nil)
        UserDefaults.standard.removeObject(forKey: "selectedProtectionMethod")
        UserDefaults.standard.removeObject(forKey: "savedPIN")
        print("url: in go to login function: \(UserDefaults.standard.baseURL)")
           if let rootVC = self.view.window?.rootViewController as? ViewController {
               rootVC.switchTo(viewController: checkingVC)
               rootVC.bottomBarView.isHidden = true
               rootVC.titlesBarView.isHidden = true
           }
           dismiss(animated: true, completion: nil)
       }
    
    func goToTimeOff() {
           let checkingVC = TimeOffViewController(nibName: "TimeOffViewController", bundle: nil)
           if let rootVC = self.view.window?.rootViewController as? ViewController {
               rootVC.switchTo(viewController: checkingVC)
               rootVC.homeButton.tintColor = .lightGray
               rootVC.timeOffButton.tintColor = .purplecolor
               rootVC.settingButton.tintColor = .lightGray
               rootVC.bottomBarView.isHidden = false
               rootVC.titlesBarView.isHidden = false
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
    
    func calculateClockDifference() {
        guard let token = UserDefaults.standard.string(forKey: "employeeToken") else {
            print("❌ No token found.")
            return
        }
        
          AttendanceViewModel().getServerTime(token: token) { result in
            switch result {
            case .success(let response):
                guard let serverTimeString = response.result?.serverTime else {
                    print("❌ Server time missing in response.")
                    return
                }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                // Use the server's timezone if available (e.g., "Africa/Cairo")
                formatter.timeZone = TimeZone(identifier: response.result?.timezone ?? "UTC")
                
                guard let serverDate = formatter.date(from: serverTimeString) else {
                    print("❌ Failed to parse server time: \(serverTimeString)")
                    return
                }
                
                let localDate = Date() // Local phone time
                let differenceInSeconds = localDate.timeIntervalSince(serverDate)
                let differenceInMinutes = differenceInSeconds / 60.0
                
                UserDefaults.standard.set(differenceInMinutes, forKey: "clockDiffMinutes")
                UserDefaults.standard.synchronize()
                
                print("🕒 Server time: \(serverTimeString) [\(response.result?.timezone ?? "UTC")]")
                print("📱 Local phone time: \(localDate)")
                print("📏 Difference: \(differenceInMinutes) minutes")
                
            case .failure(let error):
                print("❌ Failed to get server time: \(error)")
            }
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
class Inspectablelabel: UILabel {
    
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
            updateMasksToBounds()
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
            updateMasksToBounds()
        }
    }

    @IBInspectable var shadowOpacity: Float = 0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
            updateMasksToBounds()
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
            updateMasksToBounds()
        }
    }

    private func updateMasksToBounds() {
        layer.masksToBounds = shadowOpacity == 0
    }
}

@IBDesignable
class InspectableStackView: UIStackView {
    
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
class InspectableCollectionView: UICollectionView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
        }
    }
    
    
    @IBInspectable override var borderColor: UIColor? {
        didSet { layer.borderColor = borderColor?.cgColor }
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
extension Notification.Name {
    static let invoiceUpdated = Notification.Name("invoiceUpdated")
}
extension TimeOffViewController {
    func color(for state: String) -> UIColor {
        switch state {
        case "confirm":
            return UIColor.fromHex("4B644A")
        case "validate1":
            return UIColor.fromHex("ACAAAC")
        case "validate":
            return UIColor.fromHex("B7F73E")
        case "refuse":
            return UIColor.fromHex("4808C1")
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
extension String {
    func toLocalDateString() -> String? {
        // ✅ Parse incoming UTC string from backend
        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        inputFormatter.timeZone = TimeZone(identifier: "UTC") // ✅ Backend sends UTC

        guard let date = inputFormatter.date(from: self) else { return nil }

        // ✅ Format for display in device local timezone
        let outputFormatter = DateFormatter()
        outputFormatter.timeZone = TimeZone.current // ✅ Converts to Cairo (UTC+3) or any local zone

        if LanguageManager.shared.currentLanguage() == "ar" {
            outputFormatter.locale = Locale(identifier: "ar_EG")
            outputFormatter.dateFormat = "dd MMM yyyy - hh:mm a" // ٠٣ مارس ٢٠٢٦ - ١٢:٣٣ م
        } else {
            outputFormatter.locale = Locale(identifier: "en_US")
            outputFormatter.dateFormat = "dd MMM yyyy - hh:mm a" // 03 Mar 2026 - 12:33 PM
        }

        return outputFormatter.string(from: date)
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
class InspectableTableViewCell: UITableViewCell {
    
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

    // ✅ ONLY THIS ONE
    func toAPIDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"   // 🔥 REQUIRED BY BACKEND
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: self)
    }

    static func parseDate(_ text: String) -> Date? {
        let formats = [
            "MMM d, yyyy",
            "d MMM yyyy",
            "dd/MM/yyyy",
            "MM-dd-yyyy",
            "dd-MM-yyyy"
        ]

        for format in formats {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = Locale(identifier: "en_US_POSIX")
            if let date = formatter.date(from: text) {
                return date
            }
        }
        return nil
    }
}
extension Date {

    func toDurationAPIDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"   // required by /leave/duration
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }

}
extension Date {

    func toRequestAPIDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"   // required by /request_time_off
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }

}


extension UserDefaults {
    private enum Keys {
        static let dontShowProtectionScreen = "dontShowProtectionScreen"
        static let employeeToken = "employeeToken"
        static let baseURL = "baseURL"
        static let defaultURL = "defaultURL"
        static let apiKeyKey = "apiKeyKey"
        static let companyIdKey = "companyIdKey"
        static let companyLatitude = "companyLatitude"
        static let companyLongitude = "companyLongitude"
        static let allowedDistance = "allowedDistance"
        static let employeeName = "employeeName"
        static let employeeEmail = "employeeEmail"
    }
   

    var companyName: String? {
        get { string(forKey: "companyName") }
        set { set(newValue, forKey: "companyName") }
    }
    var dontShowProtectionScreen: Bool {
        get { bool(forKey: Keys.dontShowProtectionScreen) }
        set { set(newValue, forKey: Keys.dontShowProtectionScreen) }
    }
    
    var employeeToken: String? {
        get { string(forKey: Keys.employeeToken) }
        set { set(newValue, forKey: Keys.employeeToken) }
    }
    
    var employeeName: String? {
        get { string(forKey: Keys.employeeName) }
        set { set(newValue, forKey: Keys.employeeName) }
    }
    
    var employeeEmail: String? {
        get { string(forKey: Keys.employeeEmail) }
        set { set(newValue, forKey: Keys.employeeEmail) }
    }
    
    var baseURL: String? {
        get { string(forKey: Keys.baseURL) }
        set { setValue(newValue, forKey: Keys.baseURL) }
    }
    
    var defaultURL: String? {
        get { string(forKey: Keys.defaultURL) }
        set { setValue(newValue, forKey: Keys.defaultURL) }
    }
    var defaultApiKey: String {
        get { string(forKey: Keys.apiKeyKey) ?? "" }
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
extension UserDefaults {
    var mobileToken: String? {
        get { string(forKey: "mobileToken") }
        set { set(newValue, forKey: "mobileToken") }
    }
}

extension UserDefaults {

    // كل فروع الشركة (locations)
    var companyBranches: [AllowedLocation] {
        get {
            guard let data = data(forKey: "companyBranches") else { return [] }
            return (try? JSONDecoder().decode([AllowedLocation].self, from: data)) ?? []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                set(data, forKey: "companyBranches")
            }
        }
    }

    // ✅ IDs المسموح بها للموظف
    var allowedBranchIDs: [Int] {
        get {
            array(forKey: "allowedBranchIDs") as? [Int] ?? []
        }
        set {
            set(newValue, forKey: "allowedBranchIDs")
        }
    }
}



