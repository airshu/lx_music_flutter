import 'package:lx_music_flutter/app/repository/wy/crypto_utils.dart';
import 'package:lx_music_flutter/models/song_list.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';

class WYSongList {

  static List<SortItem> sortList = [
    SortItem(name: '最热', tid: 'hot', id: 'hot', isSelect: true),
  ];

  static Future getTag() async {
    String url = 'https://music.163.com/weapi/playlist/catalogue';

    var result = await HttpCore.getInstance().post(url, data: CryptoUtils.weapi({}));
    Logger.debug('$result');
  }

  static Future getHotTag() async {
    String url = 'https://music.163.com/weapi/playlist/hottags';

    var result = await HttpCore.getInstance().post(url, data: CryptoUtils.weapi({}));
    Logger.debug('$result');
  }


  static Future getTags() async {

    var res = await Future.wait([getTag(), getHotTag()]);
    return {
      'tags': res[0],
      'hotTags': res[1],
      'source': 'wy',
    };
  }

  static getList() {}

  static Future getListDetail(String id, int page) async {

  }

}
