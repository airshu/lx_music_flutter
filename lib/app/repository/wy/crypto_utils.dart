import 'dart:convert';
import 'dart:math';
import 'package:convert/convert.dart';
import 'package:lx_music_flutter/app/channels/crypto_channel.dart';
import 'package:lx_music_flutter/utils/encrypt_util.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';
import 'package:lx_music_flutter/utils/md5_util.dart';

String base64Encode(String bytes) => base64.encode(utf8.encode(bytes));

String base64Decode(String base64Str) => String.fromCharCodes(base64.decode(base64Str));

class KeyPrefix {
  static const String publicKeyStart = '-----BEGIN PUBLIC KEY-----';
  static const String publicKeyEnd = '-----END PUBLIC KEY-----';
  static const String privateKeyStart = '-----BEGIN PRIVATE KEY-----';
  static const String privateKeyEnd = '-----END PRIVATE KEY-----';
}

class AESMode {
  static const String CBC_128_PKCS7Padding = "AES/CBC/PKCS7Padding";
  static const String ECB_128_NoPadding = "AES/ECB/NoPadding";
}

class RSAPadding {
  static const String OAEPWithSHA1AndMGF1Padding = 'RSA/ECB/OAEPWithSHA1AndMGF1Padding';
  static const String NoPadding = 'RSA/ECB/NoPadding';
}

class CryptoUtils {
  static final iv = btoa('0102030405060708');
  static final presetKey = btoa('0CoJUm6Qyw8W8jud');
  static final linuxapiKey = btoa('rFgB&h#%2?^eDg:Q');
  static final publicKey = '-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDgtQn2JZ34ZC28NWYpAUd98iZ37BUrX/aKzmFbt7clFSs6sXqHauqKWqdtLkF2KexO40H1YTX8z2lSgBBOAxLsvaklV8k4cBFK9snQXE9/DDaFt6Rr7iVZMldczhC0JNgTz+SHXT6CBHuX3e9SdB1Ua44oncaTWz7OBGLbCiK45wIDAQAB\n-----END PUBLIC KEY-----';
  static final eapiKey = btoa('e82ckenh8dichen8');

  static Future<String> aesEncrypt(String text, String mode, String key, String iv) async {
    // return EncryptUtil.aesEncrypt(data, key, iv);
    var result = await CryptoChannel.aesEncrypt(text, key, iv, mode);
    return result;
  }

  static Future<String> aesDecrypt(String text, String mode, String key, String iv) async {
    // return EncryptUtil.aesDecrypt(data, key, iv);
    return await CryptoChannel.aesDecrypt(text, mode, key, iv);
  }

  static Future<String> rsaEncrypt(List<int> buffer, String key) async {
    List<int> list = [];
    for (int i = 0; i < 128 - buffer.length; i++) {
      list.add(0);
    }
    list.addAll(buffer);

    String text = base64.encode(list);
    Logger.debug('################   $text');
    var res = await rsaEncryptSync(text, key, RSAPadding.NoPadding);
    Logger.debug('rsaEncrypt=======$res');

    String result = hex.encode(base64.decode(res));
    return result;
    // var a = hex.encode(base64.decode(base64Encode(res)));
    // return base64Encode(res);
  }

  static Future rsaEncryptSync(text,String key, padding) async {
    String _k = key.replaceAll(KeyPrefix.publicKeyStart, '').replaceAll(KeyPrefix.publicKeyEnd, '');
    return await CryptoChannel.rsaEncryptSync(text, _k, padding);
  }




  static String generateRandomString(int length) {
    final random = Random();
    const chars = '0123456789';
    return String.fromCharCodes(List.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  static String btoa(String input) {
    return base64Encode(input);
  }

  static Future<Map<String, dynamic>> weapi(Map<String, dynamic> object) async {
    final text = jsonEncode(object);
    String secretKey = generateRandomString(16);
    // secretKey = '2505876171610259';
    Logger.debug('secretKey=$secretKey');
    String base64Str = base64Encode(text);

    Logger.debug('base64Str=$base64Str');
    String aes1 = await aesEncrypt(base64Str, AESMode.CBC_128_PKCS7Padding, presetKey, iv);
    Logger.debug('aesEncrypt=$aes1');
    String param1 = btoa(aes1);
    String key = btoa(secretKey);
    String params = await aesEncrypt(param1, AESMode.CBC_128_PKCS7Padding, key, iv);
    Logger.debug('params===$params');
    List<int> en1 = utf8.encode(secretKey).reversed.toList();
    Logger.debug('base64List===$en1');
    var en2 = await rsaEncrypt(en1, publicKey);
    Logger.debug('======en2=$en2');
    return {
      'params': params,
      'encSecKey': en2
    };
  }

  static Map<String, dynamic> linuxapi(Map<String, dynamic> object) {
    final text = json.encode(object);
    // final encryptedText = aesEncrypt(text, linuxapiKey, '');
    return {
      // 'eparams': EncryptUtil.base64ToHex(encryptedText).toUpperCase(),
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
      // 'params': aesDecrypt(base64Encode(data), eapiKey, iv),
      'encSecKey': EncryptUtil.encryptByPublicKeyText(publicKey, digest),
    };
  }

  static String eapiDecrypt(String cipherBuffer) {
    // final decryptedData = aesDecrypt(cipherBuffer, eapiKey, '');
    // return decryptedData;
    return '';
  }
}
