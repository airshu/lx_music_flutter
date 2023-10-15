import 'package:dio/dio.dart';
import 'package:lx_music_flutter/app/app_util.dart';
import 'package:lx_music_flutter/models/song_list.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';

class MGSongList {

  static const int limit_list = 10;
  static const int limit_song = 30;

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

  static Future getList([String? sortId, String? tagId, int page = 0]) async {
    String url = getSongListUrl(sortId, tagId, page);
    var res = await HttpCore.getInstance().get(url, headers: defaultHeaders);
    if(res['retCode'] == '100000') {
      return {
        'list': filterList(res['retMsg']['playlist']),
        'total': int.parse(res['retMsg']['countSize']),
        'limit':  limit_list,
        'source': 'mg',
      };
    }
  }

  static String getSongListUrl([String? sortId, String? tagId, int page = 0]) {
    if(tagId == null) {
      return 'https://m.music.migu.cn/migu/remoting/playlist_bycolumnid_tag?playListType=2&type=1&columnId=${sortId}&startIndex=${(page - 1) * 10}';
    }
    return 'https://m.music.migu.cn/migu/remoting/playlist_bycolumnid_tag?playListType=2&type=1&tagId=${tagId}&startIndex=${(page - 1) * 10}';
  }

  static filterList(List rawData) {
    List list = [];
    for (var item in rawData) {
      list.add({
        'play_count': AppUtil.formatPlayCount(item['playCount']),
        'id': item['playListId'],
        'author': item['createName'],
        'name': item['playListName'],
        'time': AppUtil.dateFormat(item['createTime'], 'Y-M-D'),
        'img': item['image'],
        'grade': item['grade'],
        'total': item['contentCount'],
        'desc': item['summary'],
        'source': 'mg',
      });
    }
    return list;
  }

}
