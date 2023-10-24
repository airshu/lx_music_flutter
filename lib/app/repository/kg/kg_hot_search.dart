import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/app_util.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';

class KGHotSearch {
  static Future getList() async {
    String url =
        'http://gateway.kugou.com/api/v3/search/hot_tab?signature=ee44edb9d7155821412d220bcaf509dd&appid=1005&clientver=10026&plat=0';
    var headers = {
      'dfid': '1ssiv93oVqMp27cirf2CvoF1',
      'mid': '156798703528610303473757548878786007104',
      'clienttime': 1584257267,
      'x-router': 'msearch.kugou.com',
      'user-agent': 'Android9-AndroidPhone-10020-130-0-searchrecommendprotocol-wifi',
      'kg-rc': 1,
    };

    var res = await HttpCore.getInstance().get(url, headers: headers);

    return {'source': AppConst.sourceKG, 'list': filterList(res['data']['list'])};
  }

  static filterList(rawList) {
    var list = [];
    for (var item in rawList) {
      list.add(AppUtil.decodeName(item['keyword']));
    }
    return list;
  }
}
