import 'package:lx_music_flutter/utils/http/http_client.dart';

/// 根据歌词搜索
class TXTipSearch {
  static Future search(String keyword) async {
    String url = 'https://c.y.qq.com/splcloud/fcgi-bin/smartbox_new.fcg?is_xml=0&format=json&key=${Uri.encodeComponent(keyword)}&loginUin=0&hostUin=0&format=json&inCharset=utf8&outCharset=utf-8&notice=0&platform=yqq&needNewCode=0';
    var headers = {
      'Referer': 'https://y.qq.com/portal/player.html',
    };
    var res = await HttpCore.getInstance().get(url, headers: headers);

    return res['data'].map((info) => '${info['name']} - ${info['singer']}');
  }
}
