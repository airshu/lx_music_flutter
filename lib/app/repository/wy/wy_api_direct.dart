import 'package:lx_music_flutter/app/repository/wy/crypto_utils.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';

class WYApiDirect {
  static Map qualitys = {
    '128k': 128000,
    '320k': 320000,
    'flac': 999000,
  };

  static Future getMusicUrl(MusicItem songInfo, String type) async {
    try {
      String quality = qualitys[type];
      const target_url = 'https://interface3.music.163.com/eapi/song/enhance/player/url';
      const eapiUrl = '/api/song/enhance/player/url';

      var d = {
        'ids': '[${songInfo.songmid}]',
        'br': quality,
      };

      var data = CryptoUtils.eapi(eapiUrl, d);

      var cookie = 'os=pc';
      var res = await HttpCore.getInstance().post(target_url, headers: {
        'cookie': cookie,
      });
      Logger.debug('WYApiDirect getMusicUrl  $res');
      return {'type': type, 'url': res['data']};
    } catch (e, s) {
      Logger.error('$e $s');
    }
    return {'type': type, 'url': ''};
  }
}
