import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';

class TXApiTest {
  static Future getMusicUrl(dynamic songInfo, String type) async {
    try {
      String url = 'http://ts.tempmusics.tk/url/tx/${songInfo.songmid}/${type}';
      var res = await HttpCore.getInstance().get(url, headers: AppConst.headers);
      Logger.debug('TXApiTest getMusicUrl  $res');
      return {'type': type, 'url': res['data']};
    } catch(e, s) {
      Logger.error('$e $s');
    }
    return {'type': type, 'url': ''};
  }


  static String getPic(dynamic songInfo) {
    return 'https://y.gtimg.cn/music/photo_new/T002R500x500M000${songInfo.albumId}.jpg';
  }
}
