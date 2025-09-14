//
//  AESEncryptionUtils.swift
//  HR
//
//  Created by Esther Elzek on 26/08/2025.
//

import Foundation
import CommonCrypto
 
class AESEncryptionUtils {
    
    private static let ENCRYPTION_KEY: Data = Data(base64Encoded: "/uHLGNxBtGI9WutDnPfiNoGNiKjdaNivKAoVRu1t/ks=")!
    private static let INITIALIZATION_VECTOR: Data = Data(base64Encoded: "IH+8WIrwsLOZNhUfRk6GKg==")!
    static func encryptData(_ obj: Any) throws -> String {
        let plainText = String(describing: obj)
        guard let dataToEncrypt = plainText.data(using: .utf8) else {
            throw NSError(domain: "AESEncryptionUtils",
                          code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to encode plaintext"])
        }
        let encryptedData = try aesCBCEncrypt(data: dataToEncrypt,
                                              key: ENCRYPTION_KEY,
                                              iv: INITIALIZATION_VECTOR)
        return encryptedData.base64EncodedString()
    }
    static func decryptData(_ encryptedInput: String) throws -> String {
        guard let decodedData = Data(base64Encoded: encryptedInput) else {
            throw NSError(domain: "AESEncryptionUtils",
                          code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Base64 decode failed"])
        }
        let decryptedData = try aesCBCDecrypt(data: decodedData,
                                              key: ENCRYPTION_KEY,
                                              iv: INITIALIZATION_VECTOR)
        guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
            throw NSError(domain: "AESEncryptionUtils",
                          code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "UTF8 decode failed"])
        }
        return decryptedString
    }
    // MARK: - Private AES Helpers
    private static func aesCBCEncrypt(data: Data, key: Data, iv: Data) throws -> Data {
        return try crypt(data: data, key: key, iv: iv, operation: CCOperation(kCCEncrypt))
    }
    
    private static func aesCBCDecrypt(data: Data, key: Data, iv: Data) throws -> Data {
        return try crypt(data: data, key: key, iv: iv, operation: CCOperation(kCCDecrypt))
    }
    
    private static func crypt(data: Data, key: Data, iv: Data, operation: CCOperation) throws -> Data {
        let keyLength = key.count
        guard [kCCKeySizeAES128, kCCKeySizeAES192, kCCKeySizeAES256].contains(keyLength) else {
            throw NSError(domain: "AESEncryptionUtils",
                          code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid AES key length: \(keyLength) bytes"])
        }

        var outLength = Int(0)
        let outDataCapacity = data.count + kCCBlockSizeAES128
        var outData = Data(count: outDataCapacity)

        let status = outData.withUnsafeMutableBytes { outBytes in
            data.withUnsafeBytes { dataBytes in
                key.withUnsafeBytes { keyBytes in
                    iv.withUnsafeBytes { ivBytes in
                        CCCrypt(operation,
                                CCAlgorithm(kCCAlgorithmAES),
                                CCOptions(kCCOptionPKCS7Padding),
                                keyBytes.baseAddress, keyLength,
                                ivBytes.baseAddress,
                                dataBytes.baseAddress, data.count,
                                outBytes.baseAddress, outDataCapacity,
                                &outLength)
                    }
                }
            }
        }

        guard status == kCCSuccess else {
            throw NSError(domain: "AESEncryptionUtils",
                          code: Int(status),
                          userInfo: [NSLocalizedDescriptionKey: "CCCrypt failed with status \(status)"])
        }

        outData.removeSubrange(outLength..<outData.count)
        return outData
    }

}
