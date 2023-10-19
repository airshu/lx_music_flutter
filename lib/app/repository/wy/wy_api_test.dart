import 'package:lx_music_flutter/utils/http/http_client.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';

import '../../app_const.dart';

class WYApiTest {
  static Future getMusicUrl(dynamic songInfo, String type) async {
    try {
      String url = 'http://ts.tempmusics.tk/url/wy/${songInfo.songmid}/${type}';
      var res = await HttpCore.getInstance().get(url, headers: AppConst.headers);
      Logger.debug('WYApiTest getMusicUrl  $res');
      return {'type': type, 'url': res['data']};
    } catch(e, s) {
      Logger.error('$e $s');
    }
    return {'type': type, 'url': ''};
  }
}
