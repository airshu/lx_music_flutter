import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';

class KWApiTemp {
  static Future getMusicUrl(dynamic songinfo, String type) async {
    try {
      String url = 'http://tm.tempmusics.tk/url/kw/${songinfo['songmid']}/$type';
      Map<String, dynamic> headers = {
        'User-Agent': 'lx-music request',
        AppConst.bHh: AppConst.bHh,
      };
      final result = await HttpCore.getInstance().get(url, headers: headers);
      Logger.debug('KWApiTemp getMusicUrl  $result');
      return result != null && result['code'] == 0 ? {'type': type, 'url': result['data']} : Future.error(Exception(result['msg']));
    } catch (e, s) {
      Logger.error('KWApiTemp getMusicUrl error   $e  $s');
    }
    return { 'type': type, 'url': '' };
  }
}
