import Foundation
import CommonCrypto

class AESCryptor {
    enum AESError: Error {
        case invalidKeySize
        case invalidIVSize
        case cryptoFailed(status: CCCryptorStatus)
    }
    
    func encrypt(data: Data, keyData: Data, ivData: Data, mode: String) throws -> Data {
        let cryptLength = size_t(data.count + kCCBlockSizeAES128)
        var cryptData = Data(count: cryptLength)
        
        let keyLength = size_t(kCCKeySizeAES128)
        let options = CCOptions(kCCOptionPKCS7Padding)
        
        var numBytesEncrypted: size_t = 0
        
        let cryptStatus = cryptData.withUnsafeMutableBytes { cryptBytes in
            data.withUnsafeBytes { dataBytes in
                keyData.withUnsafeBytes { keyBytes in
                    ivData.withUnsafeBytes { ivBytes in
                        CCCrypt(CCOperation(kCCEncrypt),
                               CCAlgorithm(kCCAlgorithmAES),
                               options,
                               keyBytes.baseAddress, keyLength,
                               ivBytes.baseAddress,
                               dataBytes.baseAddress, data.count,
                               cryptBytes.baseAddress, cryptLength,
                               &numBytesEncrypted)
                    }
                }
            }
        }
        
        if cryptStatus != kCCSuccess {
            throw AESError.cryptoFailed(status: cryptStatus)
        }
        
        cryptData.removeSubrange(numBytesEncrypted..<cryptData.count)
        return cryptData
    }
    
    func decrypt(data: Data, keyData: Data, ivData: Data, mode: String) throws -> Data {
        let cryptLength = size_t(data.count + kCCBlockSizeAES128)
        var cryptData = Data(count: cryptLength)
        
        let keyLength = size_t(kCCKeySizeAES128)
        let options = CCOptions(kCCOptionPKCS7Padding)
        
        var numBytesDecrypted: size_t = 0
        
        let cryptStatus = cryptData.withUnsafeMutableBytes { cryptBytes in
            data.withUnsafeBytes { dataBytes in
                keyData.withUnsafeBytes { keyBytes in
                    ivData.withUnsafeBytes { ivBytes in
                        CCCrypt(CCOperation(kCCDecrypt),
                               CCAlgorithm(kCCAlgorithmAES),
                               options,
                               keyBytes.baseAddress, keyLength,
                               ivBytes.baseAddress,
                               dataBytes.baseAddress, data.count,
                               cryptBytes.baseAddress, cryptLength,
                               &numBytesDecrypted)
                    }
                }
            }
        }
        
        if cryptStatus != kCCSuccess {
            throw AESError.cryptoFailed(status: cryptStatus)
        }
        
        cryptData.removeSubrange(numBytesDecrypted..<cryptData.count)
        return cryptData
    }
} 
