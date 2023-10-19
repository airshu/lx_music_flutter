import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';

class MGApiTest {
  static Future getMusicUrl(dynamic songInfo, String type) async {
    try {
      String url = 'http://ts.tempmusics.tk/url/mg/${songInfo['copyrightId']}/${type}';

      var headers = {
        AppConst.bHh: AppConst.bHh,
      };
      var res = await HttpCore.getInstance().get(url, headers: headers);
      Logger.debug('MGApiTest getMusicUrl  $res');
      return res['data'];
    } catch (e, s) {
      Logger.error('$e $s');
    }

    return {'type': type, 'url': ''};
  }
}
