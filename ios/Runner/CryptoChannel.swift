import Foundation
import Flutter
import CommonCrypto

@objc class CryptoChannel: NSObject, FlutterPlugin {
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "crypto_channel", binaryMessenger: registrar.messenger())
        let instance = CryptoChannel()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "aesEncrypt":
            if let args = call.arguments as? [String: Any],
               let text = args["text"] as? String,
               let key = args["key"] as? String,
               let iv = args["iv"] as? String,
               let mode = args["mode"] as? String {
                aesEncrypt(text: text, key: key, iv: iv, mode: mode, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for aesEncrypt", details: nil))
            }
            
        case "aesDecrypt":
            if let args = call.arguments as? [String: Any],
               let text = args["text"] as? String,
               let key = args["key"] as? String,
               let iv = args["iv"] as? String,
               let mode = args["mode"] as? String {
                aesDecrypt(text: text, key: key, iv: iv, mode: mode, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for aesDecrypt", details: nil))
            }
            
        case "rsaEncrypt":
            if let args = call.arguments as? [String: Any],
               let text = args["text"] as? String,
               let key = args["key"] as? String,
               let padding = args["padding"] as? String {
                rsaEncrypt(text: text, key: key, padding: padding, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for rsaEncrypt", details: nil))
            }
            
        case "rsaDecrypt":
            if let args = call.arguments as? [String: Any],
               let text = args["text"] as? String,
               let key = args["key"] as? String,
               let padding = args["padding"] as? String {
                rsaDecrypt(text: text, key: key, padding: padding, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for rsaDecrypt", details: nil))
            }
            
        case "generateRsaKey":
            generateRsaKey(result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func aesEncrypt(text: String, key: String, iv: String, mode: String, result: @escaping FlutterResult) {
        guard let keyData = Data(base64Encoded: key),
              let ivData = Data(base64Encoded: iv),
              let textData = Data(base64Encoded: text) else {
            result(FlutterError(code: "INVALID_INPUT", message: "Invalid base64 input", details: nil))
            return
        }
        
        let cryptor = AESCryptor()
        do {
            let encrypted = try cryptor.encrypt(data: textData, keyData: keyData, ivData: ivData, mode: mode)
            result(encrypted.base64EncodedString())
        } catch {
            result(FlutterError(code: "ENCRYPTION_ERROR", message: error.localizedDescription, details: nil))
        }
    }
    
    private func aesDecrypt(text: String, key: String, iv: String, mode: String, result: @escaping FlutterResult) {
        guard let keyData = Data(base64Encoded: key),
              let ivData = Data(base64Encoded: iv),
              let textData = Data(base64Encoded: text) else {
            result(FlutterError(code: "INVALID_INPUT", message: "Invalid base64 input", details: nil))
            return
        }
        
        let cryptor = AESCryptor()
        do {
            let decrypted = try cryptor.decrypt(data: textData, keyData: keyData, ivData: ivData, mode: mode)
            result(String(data: decrypted, encoding: .utf8))
        } catch {
            result(FlutterError(code: "DECRYPTION_ERROR", message: error.localizedDescription, details: nil))
        }
    }
    
    private func rsaEncrypt(text: String, key: String, padding: String, result: @escaping FlutterResult) {
        let rsaCryptor = RSACryptor()
        do {
            let encrypted = try rsaCryptor.encrypt(text: text, publicKey: key, padding: padding)
            result(encrypted)
        } catch {
            result(FlutterError(code: "RSA_ENCRYPTION_ERROR", message: error.localizedDescription, details: nil))
        }
    }
    
    private func rsaDecrypt(text: String, key: String, padding: String, result: @escaping FlutterResult) {
        let rsaCryptor = RSACryptor()
        do {
            let decrypted = try rsaCryptor.decrypt(text: text, privateKey: key, padding: padding)
            result(decrypted)
        } catch {
            result(FlutterError(code: "RSA_DECRYPTION_ERROR", message: error.localizedDescription, details: nil))
        }
    }
    
    private func generateRsaKey(result: @escaping FlutterResult) {
        let rsaCryptor = RSACryptor()
        do {
            let keyPair = try rsaCryptor.generateKeyPair()
            result([
                "publicKey": keyPair.publicKey,
                "privateKey": keyPair.privateKey
            ])
        } catch {
            result(FlutterError(code: "KEY_GENERATION_ERROR", message: error.localizedDescription, details: nil))
        }
    }
} 