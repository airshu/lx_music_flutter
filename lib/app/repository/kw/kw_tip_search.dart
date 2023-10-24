import 'package:lx_music_flutter/utils/http/http_client.dart';

/// 根据歌词搜索
class KWTipSearch {
  static Future search(String keyword) async {
    String url = 'https://tips.kuwo.cn/t.s?corp=kuwo&newver=3&p2p=1&notrace=0&c=mbox&w=${Uri.encodeComponent(keyword)}&encoding=utf8&rformat=json';
    var headers = {
      'Referer': 'http://www.kuwo.cn/',
    };
    var res = await HttpCore.getInstance().get(url, headers: headers);

    return res['WORDITEMS'].map((info) => info['RELWORD']);
  }
}
