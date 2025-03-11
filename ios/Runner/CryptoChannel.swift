import Foundation
import Flutter
import CommonCrypto
import os.log

public class CryptoChannel: NSObject, FlutterPlugin {
    private static let logger = OSLog(subsystem: "com.example.lxMusicFlutter", category: "CryptoChannel")
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        print("CryptoChannel register >>>>>>> print")
        os_log("CryptoChannel registering...", log: logger, type: .info)
        
        let channel = FlutterMethodChannel(name: "crypto_channel", binaryMessenger: registrar.messenger())
        let instance = CryptoChannel()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        os_log("CryptoChannel registered successfully", log: logger, type: .info)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        os_log("Handling method: %{public}@", log: Self.logger, type: .debug, call.method)
        
        switch call.method {
        case "aesEncrypt":
            if let args = call.arguments as? [String: Any],
               let text = args["text"] as? String,
               let key = args["key"] as? String,
               let iv = args["iv"] as? String,
               let mode = args["mode"] as? String {
                os_log("aesEncrypt called with mode: %{public}@", log: Self.logger, type: .debug, mode)
                aesEncrypt(text: text, key: key, iv: iv, mode: mode, result: result)
            } else {
                os_log("Invalid arguments for aesEncrypt", log: Self.logger, type: .error)
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
            os_log("generateRsaKey called", log: Self.logger, type: .debug)
            generateRsaKey(result: result)
            
        default:
            os_log("Method not implemented: %{public}@", log: Self.logger, type: .error, call.method)
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func aesEncrypt(text: String, key: String, iv: String, mode: String, result: @escaping FlutterResult) {
        guard let keyData = Data(base64Encoded: key),
              let ivData = Data(base64Encoded: iv),
              let textData = Data(base64Encoded: text) else {
            os_log("Invalid base64 input for aesEncrypt", log: Self.logger, type: .error)
            result(FlutterError(code: "INVALID_INPUT", message: "Invalid base64 input", details: nil))
            return
        }
        
        let cryptor = AESCryptor()
        do {
            let encrypted = try cryptor.encrypt(data: textData, keyData: keyData, ivData: ivData, mode: mode)
            os_log("AES encryption successful", log: Self.logger, type: .debug)
            result(encrypted.base64EncodedString())
        } catch {
            os_log("AES encryption failed: %{public}@", log: Self.logger, type: .error, error.localizedDescription)
            result(FlutterError(code: "ENCRYPTION_ERROR", message: error.localizedDescription, details: nil))
        }
    }
    
    private func aesDecrypt(text: String, key: String, iv: String, mode: String, result: @escaping FlutterResult) {
        guard let keyData = Data(base64Encoded: key),
              let ivData = Data(base64Encoded: iv),
              let textData = Data(base64Encoded: text) else {
            os_log("Invalid base64 input for aesDecrypt", log: Self.logger, type: .error)
            result(FlutterError(code: "INVALID_INPUT", message: "Invalid base64 input", details: nil))
            return
        }
        
        let cryptor = AESCryptor()
        do {
            let decrypted = try cryptor.decrypt(data: textData, keyData: keyData, ivData: ivData, mode: mode)
            os_log("AES decryption successful", log: Self.logger, type: .debug)
            result(String(data: decrypted, encoding: .utf8))
        } catch {
            os_log("AES decryption failed: %{public}@", log: Self.logger, type: .error, error.localizedDescription)
            result(FlutterError(code: "DECRYPTION_ERROR", message: error.localizedDescription, details: nil))
        }
    }
    
    private func rsaEncrypt(text: String, key: String, padding: String, result: @escaping FlutterResult) {
        os_log("Starting RSA encryption", log: Self.logger, type: .debug)
        let rsaCryptor = RSACryptor()
        do {
            let encrypted = try rsaCryptor.encrypt(text: text, publicKey: key, padding: padding)
            os_log("RSA encryption successful", log: Self.logger, type: .debug)
            result(encrypted)
        } catch {
            os_log("RSA encryption failed: %{public}@", log: Self.logger, type: .error, error.localizedDescription)
            result(FlutterError(code: "RSA_ENCRYPTION_ERROR", message: error.localizedDescription, details: nil))
        }
    }
    
    private func rsaDecrypt(text: String, key: String, padding: String, result: @escaping FlutterResult) {
        os_log("Starting RSA decryption", log: Self.logger, type: .debug)
        let rsaCryptor = RSACryptor()
        do {
            let decrypted = try rsaCryptor.decrypt(text: text, privateKey: key, padding: padding)
            os_log("RSA decryption successful", log: Self.logger, type: .debug)
            result(decrypted)
        } catch {
            os_log("RSA decryption failed: %{public}@", log: Self.logger, type: .error, error.localizedDescription)
            result(FlutterError(code: "RSA_DECRYPTION_ERROR", message: error.localizedDescription, details: nil))
        }
    }
    
    private func generateRsaKey(result: @escaping FlutterResult) {
        os_log("Starting RSA key pair generation", log: Self.logger, type: .debug)
        let rsaCryptor = RSACryptor()
        do {
            let keyPair = try rsaCryptor.generateKeyPair()
            os_log("RSA key pair generated successfully", log: Self.logger, type: .debug)
            result([
                "publicKey": keyPair.publicKey,
                "privateKey": keyPair.privateKey
            ])
        } catch {
            os_log("RSA key generation failed: %{public}@", log: Self.logger, type: .error, error.localizedDescription)
            result(FlutterError(code: "KEY_GENERATION_ERROR", message: error.localizedDescription, details: nil))
        }
    }
}
