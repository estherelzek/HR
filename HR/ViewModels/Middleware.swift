//
//  Middleware.swift
//  HR
//
//  Created by Esther Elzek on 26/08/2025.
//

import Foundation

class Middleware {
    var companyId: String
    var apiKey: String
    var baseUrl: String

    private init(encryptedInput: String) throws {
        let decryptedData = try AESEncryptionUtils.decryptData(encryptedInput)
        print("Decrypted text: [\(decryptedData)]")  // 👈 Add this
        let (cid, key, url) = try Middleware.parseDecryptedData(decryptedData)
        self.companyId = cid
        self.apiKey = key
        self.baseUrl = url
    }

    private static func parseDecryptedData(_ decryptedData: String) throws -> (String, String, String) {
        let params = decryptedData.components(separatedBy: Middleware.DATA_DELIMITER)
        guard params.count == 3 else {
            throw NSError(domain: "Middleware",
                          code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid decrypted data format"])
        }
        return (params[0], params[1], params[2])
    }

    public var description: String {
        return [companyId, apiKey, baseUrl].joined(separator: Middleware.DATA_DELIMITER)
    }

    // MARK: - Singleton
    private static let DATA_DELIMITER = "|§|"
    private static var instance: Middleware? = nil

    static func initialize(_ encryptedInput: String) throws -> Middleware {
        if let existing = instance {
            return existing
        }
        let newInstance = try Middleware(encryptedInput: encryptedInput)
        instance = newInstance
        return newInstance
    }
}

extension Middleware {
   
        private static let companyIdKey = "companyIdKey"
        private static let apiKeyKey = "apiKeyKey"
        private static let baseUrlKey = "baseURL"   // FIX: must match UserDefaults
    

    func saveToUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.set(companyId, forKey: "companyIdKey")
        defaults.set(apiKey, forKey: "apiKeyKey")
        defaults.set(baseUrl, forKey: "baseURL")
    }


    static func loadFromUserDefaults() -> Middleware? {
        let defaults = UserDefaults.standard
        guard let cid = defaults.string(forKey: Middleware.companyIdKey),
              let key = defaults.string(forKey: Middleware.apiKeyKey),
              let url = defaults.string(forKey: Middleware.baseUrlKey) else {
            return nil
        }
        // Build a Middleware instance manually
        let fakeEncrypted = "" // placeholder, we already have decrypted values
        let middleware = try? Middleware(encryptedInput: fakeEncrypted) // won't work directly
        // Instead: build a lightweight object
        return Middleware.manual(companyId: cid, apiKey: key, baseUrl: url)
    }

    // Helper initializer for restoring from UserDefaults
    private static func manual(companyId: String, apiKey: String, baseUrl: String) -> Middleware {
        let obj = Middleware.__empty()
        obj.companyId = companyId
        obj.apiKey = apiKey
        obj.baseUrl = baseUrl
        return obj
    }

    // Trick: private "empty" init (workaround since properties are let)
    private static func __empty() -> Middleware {
        return try! Middleware(encryptedInput: "dummy") // won't be used
    }
}
