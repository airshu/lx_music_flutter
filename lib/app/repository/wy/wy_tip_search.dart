import 'package:lx_music_flutter/app/app_util.dart';
import 'package:lx_music_flutter/app/repository/wy/crypto_utils.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';

/// 根据歌词搜索
class WYTipSearch {
  static Future search(String keyword) async {
    String url = 'https://music.163.com/weapi/search/suggest/web';
    var headers = {
      'referer': 'https://music.163.com/',
      'origin': 'https://music.163.com/',
    };
    var form = CryptoUtils.weapi({'s': keyword});
    var res = await HttpCore.getInstance().get(url, headers: headers, data: form);

    return res['result']['songs'].map((info) => '${info['name']} - ${AppUtil.formatSingerName(singers: info['artists'])}');
  }
}
