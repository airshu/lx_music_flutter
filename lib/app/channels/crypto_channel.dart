import 'package:flutter/services.dart';

/// 原生通道
class CryptoChannel {
  static const platform = MethodChannel('crypto_channel');

  static Future aesEncrypt(text, key, iv, mode) async {
    var param = {
      'text': text,
      'mode': mode,
      'key': key,
      'iv': iv,
    };
    var result = await platform.invokeMethod('aesEncrypt', param);
    return result;
  }

  static Future aesDecrypt(text, key, iv, mode) async {
    var param = {
      'text': text,
      'mode': mode,
      'key': key,
      'iv': iv,
    };
    var result = await platform.invokeMethod('aesDecrypt', param);
    return result;
  }

  static Future rsaEncrypt(text, key, padding) async {
    var param = {
      'text': text,
      'key': key,
      'padding': padding,
    };
    var result = await platform.invokeMethod('rsaEncrypt', param);
    return result;
  }

  static Future rsaEncryptSync(text, key, padding) async {
    return rsaEncrypt(text, key, padding);
    // var param = {
    //   'text': text,
    //   'key': key,
    //   'padding': padding,
    // };
    // var result = await platform.invokeMethod('rsaEncryptSync', param);
    // return result;
  }

  static Future rsaDecrypt(text, key, padding) async {
    var param = {
      'text': text,
      'key': key,
      'padding': padding,
    };
    var result = await platform.invokeMethod('rsaDecrypt', param);
    return result;
  }

  /// [return]
  /// {
  ///   'publicKey': '公钥',
  ///   'privateKey: '',
  /// }
  static Future generateRsaKey() async {
    var result = await platform.invokeMethod('generateRsaKey', {});
    return result;

  }
}
