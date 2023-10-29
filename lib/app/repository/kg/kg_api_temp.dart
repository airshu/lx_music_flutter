import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';

class KGApiTemp {
  static Future getMusicUrl(MusicItem songInfo, String type) async {
    try {
      String url = 'http://ts.tempmusics.tk/url/kg/${songInfo.qualityMap[type]?['hash']}/${type}';
      var res = await HttpCore.getInstance().get(url, headers: AppConst.headers);
      Logger.debug('KGApiTemp getMusicUrl  $res');
      return {'type': type, 'url': res['data']};
    } catch (e, s) {
      Logger.error('$e $s');
    }
    return {'type': type, 'url': ''};
  }

  static Future getPic(dynamic songInfo) async {
    String url = 'http://ts.tempmusics.tk/pic/kg/${songInfo.hash}';
    var res = await HttpCore.getInstance().get(url, headers: AppConst.headers);
    return res['data'];
  }

  static Future getLyric(dynamic songInfo) async {
    String url = 'http://ts.tempmusics.tk/lrc/kg/${songInfo.hash}';
    var res = await HttpCore.getInstance().get(url, headers: AppConst.headers);
    return res['data'];
  }


}
