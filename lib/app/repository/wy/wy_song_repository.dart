import 'dart:convert';

import 'package:lx_music_flutter/services/app_service.dart';
import 'package:lx_music_flutter/utils/encrypt_util.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';
import 'package:lx_music_flutter/utils/md5_util.dart';

class WYSongRepository {
  static Future eapiRequest(url, data) async {
    var result = await HttpCore.getInstance().post('http://interface.music.163.com/eapi/batch',
        headers: {
          'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.90 Safari/537.36',
          'origin': 'https://music.163.com',
        },
        data: eapi(url, data));
    return result;
  }

  static Map eapi(String url, object) {
    String text = (object is String) ? json.encode(object) : object;
    String message = 'nobody${url}use${text}md5forencrypt';
    String digest = MD5Util.generateMD5(message);
    String data = '${url}-36cd479b6b5-${text}-36cd479b6b5-${digest}';

    return {
      'params': EncryptUtil.aesDecrypt(EncryptUtil.encodeBase64(data), AppService.instance.eapiKey, AppService.instance.iv),
      'encSecKey': EncryptUtil.encryptByPublicKeyText(AppService.instance.publicKey, digest),
    };
  }
}
