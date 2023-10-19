import 'package:dio/dio.dart';
import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';

class KWApiTest {
  static Future getMusicUrl(dynamic songinfo, String type) async {
    try {
      Map<String, dynamic> headers = {
        'User-Agent': 'lx-music request',
        AppConst.bHh: AppConst.bHh,
        'family': 4,
      };
      String url = 'http://ts.tempmusics.tk/url/kw/${songinfo['songmid']}/$type';
      // headers = await getHeader(url, headers);
      final result = await HttpCore.getInstance()
          .get(url, headers: headers, options: Options(sendTimeout: const Duration(seconds: 15), method: 'get'));
      Logger.error('KWApiTest getMusicUrl  $result');
      return result['code'] == 0 ? {'type': type, 'url': result['data']} : Future.error(Exception(result.fail));
    } catch (e, s) {
      Logger.error('KWApiTest getMusicUrl error  $e  $s');
    }
    return {'type': type, 'url': ''};
  }
}
