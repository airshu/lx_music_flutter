import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';

class EncryptUtil {
  /// 根据公钥进行RSA加密
  /// [file] 'assets/data/rsa_public_key.pem'
  /// [msg] 待加密明文
  static Future<String> encryptByFile(String file, String msg) async {
    var publicKeyStr = await rootBundle.loadString(file);
    RSAPublicKey publicKey = RSAKeyParser().parse(publicKeyStr) as RSAPublicKey;
    final encrypter = Encrypter(RSA(publicKey: publicKey));

    List<int> sourceBytes = utf8.encode(msg);
    int inputLen = sourceBytes.length;
    int maxLen = 117;
    List<int> totalBytes = [];
    for (var i = 0; i < inputLen; i += maxLen) {
      int endLen = inputLen - i;
      List<int> item;
      if (endLen > maxLen) {
        item = sourceBytes.sublist(i, i + maxLen);
      } else {
        item = sourceBytes.sublist(i, i + endLen);
      }
      totalBytes.addAll(encrypter.encryptBytes(item).bytes);
    }
    return base64.encode(totalBytes);
  }

  /// 根据公钥内容进行RSA加密
  /// [publicKeyText] 公钥内容，支持没有header的方式
  /// [msg] 待加密明文
  static String encryptByPublicKeyText(String publicKeyText, String msg) {
    if (!publicKeyText.contains('BEGIN PUBLIC KEY')) {
      publicKeyText = '-----BEGIN PUBLIC KEY-----\n' + publicKeyText + '\n-----END PUBLIC KEY-----';
    }
    RSAPublicKey publicKey = RSAKeyParser().parse(publicKeyText) as RSAPublicKey;
    final encrypter = Encrypter(RSA(publicKey: publicKey));

    List<int> sourceBytes = utf8.encode(msg);
    int inputLen = sourceBytes.length;
    int maxLen = 117;
    List<int> totalBytes = [];
    for (var i = 0; i < inputLen; i += maxLen) {
      int endLen = inputLen - i;
      List<int> item;
      if (endLen > maxLen) {
        item = sourceBytes.sublist(i, i + maxLen);
      } else {
        item = sourceBytes.sublist(i, i + endLen);
      }
      totalBytes.addAll(encrypter.encryptBytes(item).bytes);
    }
    return base64.encode(totalBytes);
  }

  /// 根据私钥解密
  /// [file] 私钥文件 'assets/data/rsa_private_key.pem'
  /// [msg] 待解密内容
  static Future<String> decodeByFile(String file, String msg) async {
    var publicKeyStr = await rootBundle.loadString(file);
    RSAPublicKey publicKey = RSAKeyParser().parse(publicKeyStr) as RSAPublicKey;
    final encrypter = Encrypter(RSA(publicKey: publicKey));

    Uint8List sourceBytes = base64.decode(msg);
    int inputLen = sourceBytes.length;
    int maxLen = 128;
    List<int> totalBytes = [];
    for (var i = 0; i < inputLen; i += maxLen) {
      int endLen = inputLen - i;
      Uint8List item;
      if (endLen > maxLen) {
        item = sourceBytes.sublist(i, i + maxLen);
      } else {
        item = sourceBytes.sublist(i, i + endLen);
      }
      totalBytes.addAll(encrypter.decryptBytes(Encrypted(item)));
    }
    return utf8.decode(totalBytes);
  }

  /// 根据私钥解密
  /// [file] 私钥文件 'assets/data/rsa_private_key.pem'
  /// [msg] 待解密内容
  static Future<String> decodeByPrivateKeyText(String privateKeyText, String msg) async {
    RSAPublicKey publicKey = RSAKeyParser().parse(privateKeyText) as RSAPublicKey;
    final encrypter = Encrypter(RSA(publicKey: publicKey));

    Uint8List sourceBytes = base64.decode(msg);
    int inputLen = sourceBytes.length;
    int maxLen = 128;
    List<int> totalBytes = [];
    for (var i = 0; i < inputLen; i += maxLen) {
      int endLen = inputLen - i;
      Uint8List item;
      if (endLen > maxLen) {
        item = sourceBytes.sublist(i, i + maxLen);
      } else {
        item = sourceBytes.sublist(i, i + endLen);
      }
      totalBytes.addAll(encrypter.decryptBytes(Encrypted(item)));
    }
    return utf8.decode(totalBytes);
  }


  ///Base64编码
  static String encodeBase64(String data) {
    return base64Encode(utf8.encode(data));
  }

  ///Base64解码
  static String decodeBase64(String data) {
    return String.fromCharCodes(base64Decode(data));
  }

  static String base64ToHex(String source) =>
      base64Decode(LineSplitter.split(source).join()).map((e) => e.toRadixString(16).padLeft(2, '0'))
          .join();

  ///AES加密
  /// [key] 密钥
  /// [iv] 偏移量
  static aesEncrypt(String plainText, String key, String iv) {
    try {
      final _key = Key.fromUtf8(key);
      final _iv = IV.fromUtf8(iv);
      /// 这里可以配置类型，
      final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
      final encrypted = encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base16;
    } catch (err) {
      print("aes encode error:$err");
      return plainText;
    }
  }

  ///AES解密
  static dynamic aesDecrypt(String encrypted, String key, String iv) {
    try {
      final _key = Key.fromUtf8(key);
      final _iv = IV.fromUtf8(iv);
      final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
      final decrypted = encrypter.decrypt16(encrypted, iv: _iv);
      return decrypted;
    } catch (err) {
      print("aes decode error:$err");
      return encrypted;
    }
  }

}
