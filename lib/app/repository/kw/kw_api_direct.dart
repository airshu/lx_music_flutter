import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';

class KWApiDirect {
  static Future getMusicUrl(MusicItem songinfo, String type) async {
    try {
      String url = 'http://www.kuwo.cn/api/v1/www/music/playUrl?mid=${songinfo.songmid}&type=music&br=$type';
      Map<String, dynamic> headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:82.0) Gecko/20100101 Firefox/82.0',
        'Referer': 'http://kuwo.cn/',
        'cookie': 'Hm_Iuvt_cdb524f42f0cer9b268e4v7y734w5esq24=4cGcsx3ej3tkYfeGrFtdS2kSZ6YD3nbD',
        'Secret': '14da58a88a83170f11c3a63bb0ff6aec68a7487b64551a1f997356d719980a2b028f34f5',
        'credentials': 'omit',
      };
      final result = await HttpCore.getInstance().get(url, headers: headers);
      if (result['success'] == false) {
        return {'type': type, 'url': ''};
      }
      return {'type': type, 'url': result['data']['url']};
    } catch (e, s) {
      Logger.error('$e $s');
    }

    return {'type': type, 'url': ''};
  }
}
