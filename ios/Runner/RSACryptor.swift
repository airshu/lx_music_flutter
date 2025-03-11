import Foundation
import Security

class RSACryptor {
    struct KeyPair {
        let publicKey: String
        let privateKey: String
    }
    
    enum RSAError: Error {
        case keyGenerationFailed
        case invalidKeyFormat
        case encryptionFailed
        case decryptionFailed
    }
    
    func generateKeyPair() throws -> KeyPair {
        var publicKey, privateKey: SecKey?
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 2048
        ]
        
        let status = SecKeyGeneratePair(attributes as CFDictionary, &publicKey, &privateKey)
        guard status == errSecSuccess else {
            throw RSAError.keyGenerationFailed
        }
        
        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey!, nil) as Data?,
              let privateKeyData = SecKeyCopyExternalRepresentation(privateKey!, nil) as Data? else {
            throw RSAError.keyGenerationFailed
        }
        
        return KeyPair(
            publicKey: publicKeyData.base64EncodedString(),
            privateKey: privateKeyData.base64EncodedString()
        )
    }
    
    func encrypt(text: String, publicKey: String, padding: String) throws -> String {
        guard let data = Data(base64Encoded: text),
              let keyData = Data(base64Encoded: publicKey) else {
            throw RSAError.invalidKeyFormat
        }
        
        var error: Unmanaged<CFError>?
        guard let publicKey = SecKeyCreateWithData(keyData as CFData, [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic
        ] as CFDictionary, &error) else {
            throw RSAError.invalidKeyFormat
        }
        
        guard let encryptedData = SecKeyCreateEncryptedData(publicKey,
                                                          .rsaEncryptionPKCS1,
                                                          data as CFData,
                                                          &error) as Data? else {
            throw RSAError.encryptionFailed
        }
        
        return encryptedData.base64EncodedString()
    }
    
    func decrypt(text: String, privateKey: String, padding: String) throws -> String {
        guard let data = Data(base64Encoded: text),
              let keyData = Data(base64Encoded: privateKey) else {
            throw RSAError.invalidKeyFormat
        }
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateWithData(keyData as CFData, [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPrivate
        ] as CFDictionary, &error) else {
            throw RSAError.invalidKeyFormat
        }
        
        guard let decryptedData = SecKeyCreateDecryptedData(privateKey,
                                                          .rsaEncryptionPKCS1,
                                                          data as CFData,
                                                          &error) as Data? else {
            throw RSAError.decryptionFailed
        }
        
        guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
            throw RSAError.decryptionFailed
        }
        
        return decryptedString
    }
}
