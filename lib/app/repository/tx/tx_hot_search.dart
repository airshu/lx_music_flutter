import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/app_util.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';

/// 热门词
class TXHotSearch {
  static Future getList() async {
    String url = 'https://u.y.qq.com/cgi-bin/musicu.fcg';
    var headers = {
      'Referer': 'https://y.qq.com/portal/player.html',
    };
    var body = {
      'comm': {
        'ct': '19',
        'cv': '1803',
        'guid': '0',
        'patch': '118',
        'psrf_access_token_expiresAt': 0,
        'psrf_qqaccess_token': '',
        'psrf_qqopenid': '',
        'psrf_qqunionid': '',
        'tmeAppID': 'qqmusic',
        'tmeLoginType': 0,
        'uin': '0',
        'wid': '0',
      },
      'hotkey': {
        'method': 'GetHotkeyForQQMusicPC',
        'module': 'tencent_musicsoso_hotkey.HotkeyService',
        'param': {
          'search_id': '',
          'uin': 0,
        },
      }
    };

    var res = await HttpCore.getInstance().post(url, headers: headers, data: body);

    return {'source': AppConst.sourceTX, 'list': filterList(res['hotkey']['data']['vec_hotkey'])};
  }

  static filterList(rawList) {
    return rawList.map((item) => item.query).toList();
  }
}
