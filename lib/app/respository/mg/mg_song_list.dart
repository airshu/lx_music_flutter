import 'package:lx_music_flutter/models/song_list.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';

class MGSongList {
  static List<SortItem> sortList = [
    SortItem(name: '推荐', tid: 'recommend', id: '15127315', isSelect: true),
    SortItem(name: '最新', tid: 'new', id: '15127272'),
  ];

  static const String tagsUrl = 'https://app.c.nf.migu.cn/MIGUM3.0/v1.0/template/musiclistplaza-taglist/release';

  static const Map<String, dynamic> defaultHeaders = {
    'User-Agent':
        'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1',
    'Referer': 'https://m.music.migu.cn/',
  };

  static Future getTag() async {
    var res = await HttpCore.getInstance().get(tagsUrl, headers: defaultHeaders);
    if (res['code'] == '000000') {
      return filterTagInfo(res['data']);
    }
  }

  static Future getTags() async {
    return await getTag();
  }

  static Map filterTagInfo(List rawList) {
    var hotTags = rawList[0]['content'].map((e) {
      return {
        'id': e['texts'][1],
        'name': e['texts'][0],
        'source': 'mg',
      };
    }).toList();
    return {
      'hotTags': hotTags,
      'tags': rawList.sublist(1).map((e) {
        return {
          'name': e['header']['title'],
          'list': e['content'].map((e) {
            return {
              'id': e['texts'][1],
              'name': e['texts'][0],
              'source': 'mg',
            };
          }).toList(),
        };
      }).toList(),
      'source': 'mg',
    };
  }

  static Future getList() async {}
}
