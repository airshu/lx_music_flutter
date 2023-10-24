import 'package:lx_music_flutter/utils/http/http_client.dart';

/// 根据歌词搜索
class MGTipSearch {
  static Future search(String keyword) async {
    String url = 'https://music.migu.cn/v3/api/search/suggest?keyword=${Uri.encodeComponent(keyword)}';
    var headers = {
      'referer': 'https://music.migu.cn/v3',
    };
    var res = await HttpCore.getInstance().get(url, headers: headers);

    return res['songs'].map((info) => '${info['name']} - ${info['singerName']}');
  }
}
