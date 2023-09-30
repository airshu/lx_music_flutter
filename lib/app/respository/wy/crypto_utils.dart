import 'dart:convert';
import 'dart:math';

import 'package:lx_music_flutter/utils/encrypt_util.dart';
import 'package:lx_music_flutter/utils/md5_util.dart';
import 'package:pointycastle/random/fortuna_random.dart';

String base64Encode(String bytes) => base64.encode(utf8.encode(bytes));
String base64Decode(String base64Str) => String.fromCharCodes(base64.decode(base64Str));

class CryptoUtils {
  static final iv = base64Decode('0102030405060708');
  static final presetKey = base64Decode('0CoJUm6Qyw8W8jud');
  static final linuxapiKey = base64Decode('rFgB&h#%2?^eDg:Q');
  static final publicKey = '''-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDgtQn2JZ34ZC28NWYpAUd98iZ37BUrX/aKzmFbt7clFSs6sXqHauqKWqdtLkF2KexO40H1YTX8z2lSgBBOAxLsvaklV8k4cBFK9snQXE9/DDaFt6Rr7iVZMldczhC0JNgTz+SHXT6CBHuX3e9SdB1Ua44oncaTWz7OBGLbCiK45wIDAQAB
-----END PUBLIC KEY-----''';
  static final eapiKey = base64Decode('e82ckenh8dichen8');

  static String aesEncrypt(String data, String key, String iv) {
    return EncryptUtil.aesDecrypt(data, key, iv);
  }

  static String aesDecrypt(String data, String key, String iv) {
    return EncryptUtil.aesDecrypt(data, key, iv);
  }

  static String rsaEncrypt(String data, String publicKey) {
    return EncryptUtil.encryptByPublicKeyText(publicKey, data);
  }

  static String generateRandomString(int length) {
    return Random().nextDouble().toString().substring(2,18);
  }

  static Map<String, dynamic> weapi(Map<String, dynamic> object) {
    final text = json.encode(object);
    final secretKey = generateRandomString(16);
    final base64Str = base64Encode(text);
    var params = base64Encode(aesEncrypt(base64Str, presetKey, iv));
    params = aesEncrypt(params, presetKey, iv);

    final encryptedSecretKey = rsaEncrypt(secretKey, publicKey);
    final encSecKey = EncryptUtil.base64ToHex(encryptedSecretKey);
    return {
      'params': params,
      'encSecKey': encSecKey,
    };
  }



  static Map<String, dynamic> linuxapi(Map<String, dynamic> object) {
    final text = json.encode(object);
    final encryptedText = aesEncrypt(text, linuxapiKey, '');
    return {
      'eparams': EncryptUtil.base64ToHex(encryptedText).toUpperCase(),
    };
  }

  static Map<String, dynamic> eapi(String url, dynamic object) {
    // final text = (object is Map) ? json.encode(object) : object.toString();
    // final message = 'nobody${url}use${text}md5forencrypt';
    // final digest = md5.convert(utf8.encode(message)).toString();
    // final data = '$url-36cd479b6b5-$text-36cd479b6b5-$digest';
    // final encryptedData = aesEncrypt(utf8.encode(data), eapiKey, []);
    // return {
    //   'params': hex.encode(encryptedData).toUpperCase(),
    // };

    String text = (object is String) ? json.encode(object) : object;
    String message = 'nobody${url}use${text}md5forencrypt';
    String digest = MD5Util.generateMD5(message);
    String data = '${url}-36cd479b6b5-${text}-36cd479b6b5-${digest}';

    return {
      'params': aesDecrypt(base64Encode(data), eapiKey, iv),
      'encSecKey': EncryptUtil.encryptByPublicKeyText(publicKey, digest),
    };
  }




  static String eapiDecrypt(String cipherBuffer) {
    final decryptedData = aesDecrypt(cipherBuffer, eapiKey, '');
    return decryptedData;
  }
}