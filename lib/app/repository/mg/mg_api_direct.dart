import 'package:lx_music_flutter/utils/http/http_client.dart';

import '../../../utils/log/logger.dart';

class MGApiDirect {
  static const qualitys = {
    '128k': 'PQ',
    '320k': 'HQ',
    'flac': 'SQ',
    'flac32bit': 'ZQ',
  };

  static Future getMusicUrl(dynamic songInfo, String type) async {
    try {
      String quality = qualitys[type] ?? '';
      String url =
          'https://app.c.nf.migu.cn/MIGUM2.0/strategy/listen-url/v2.2?netType=01&resourceType=E&songId=${songInfo['songmid']}&toneFlag=${quality}';
      var headers = {
        'channel': '0146951',
        'uid': 1234,
      };
      var res = await HttpCore.getInstance().get(url, headers: headers);
      Logger.debug('MGApiDirect getMusicUrl  $res');
      String? playUrl = res['data']?['url'];
      if (playUrl != null) {
        if (playUrl.startsWith('//')) playUrl = 'https:${playUrl}';

        return {'type': type, 'url': playUrl!.replaceAll('\+', '%2B')};
      }

      return {'type': type, 'url': ''};
    } catch (e, s) {
      Logger.error('$e $s');
    }

    return {'type': type, 'url': ''};
  }
}
