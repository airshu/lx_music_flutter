import 'package:lx_music_flutter/utils/http/http_client.dart';

/// 根据词搜索热门词
class KGTipSearch {
  static Future search(String keyword) async {
    String url = 'https://searchtip.kugou.com/getSearchTip?MusicTipCount=10&keyword=${Uri.encodeComponent(keyword)}';
    var headers = {
      'referer': 'https://www.kugou.com/',
    };
    var res = await HttpCore.getInstance().get(url, headers: headers);

    return res['songs'].map((info) => info['HintInfo']);
  }
}
