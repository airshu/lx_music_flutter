import 'package:lx_music_flutter/app/respository/wy/crypto_utils.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';

class WYSongList {
  static Future getTag() async {
    String url = 'https://music.163.com/weapi/playlist/catalogue';

    var result = await HttpCore.getInstance().post(url, data: CryptoUtils.weapi({}));
    Logger.debug('$result');
  }

  static Future getHotTag() async {
    String url = 'https://music.163.com/weapi/playlist/hottags';

    var result = await HttpCore.getInstance().post(url, data: CryptoUtils.weapi({}));
    Logger.debug('$result');
  }
}
