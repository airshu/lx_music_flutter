import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';

class KWHotSearch {
  static Future getList() async {
    String url =
        'http://hotword.kuwo.cn/hotword.s?prod=kwplayer_ar_9.3.0.1&corp=kuwo&newver=2&vipver=9.3.0.1&source=kwplayer_ar_9.3.0.1_40.apk&p2p=1&notrace=0&uid=0&plat=kwplayer_ar&rformat=json&encoding=utf8&tabid=1';
    var headers = {
      'User-Agent': 'Dalvik/2.1.0 (Linux; U; Android 9;)',
    };

    var res = await HttpCore.getInstance().get(url, headers: headers);

    return {'source': AppConst.sourceKW, 'list': filterList(res['tagvalue'])};
  }

  static filterList(rawList) {
    return rawList.map((item) => item.key).toList();
  }
}
