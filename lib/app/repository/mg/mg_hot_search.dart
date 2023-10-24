import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/app_util.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';

class MGHotSearch {
  static Future getList() async {
    String url = 'http://jadeite.migu.cn:7090/music_search/v3/search/hotword';

    var res = await HttpCore.getInstance().get(url);

    return {'source': AppConst.sourceMG, 'list': filterList(res['data']['hotwords'][0]['hotwordList'])};
  }

  static filterList(rawList) {
    return rawList.filter((item) => item.resourceType == 'song').map((item) => item.word).toList();
  }
}
