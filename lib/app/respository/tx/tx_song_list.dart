import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:lx_music_flutter/models/song_list.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';

class TXSongList {
  static List<SortItem> sortList = [
    SortItem(name: '最热', tid: 'hot', id: '5', isSelect: true),
    SortItem(name: '最新', tid: 'new', id: '2'),
  ];

  static const String tagsUrl =
      'https://u.y.qq.com/cgi-bin/musicu.fcg?loginUin=0&hostUin=0&format=json&inCharset=utf-8&outCharset=utf-8&notice=0&platform=wk_v15.json&needNewCode=0&data=%7B%22tags%22%3A%7B%22method%22%3A%22get_all_categories%22%2C%22param%22%3A%7B%22qq%22%3A%22%22%7D%2C%22module%22%3A%22playlist.PlaylistAllCategoriesServer%22%7D%7D';
  static const String hotTagUrl = 'https://c.y.qq.com/node/pc/wk_v15/category_playlist.html';

  static RegExp hotTagHtmlRegExp = RegExp(r'class="c_bg_link js_tag_item" data-id="\w+">.+?</a>', multiLine: true);
  static RegExp hotTagRegExp = RegExp(r'data-id="(\w+)">(.+?)</a>');
  static RegExp listDetailLinkRegExp = RegExp(r'/playlist/(\d+)');
  static RegExp listDetailLink2RegExp = RegExp(r'id=(\d+)');

  static List filterTagInfo(List rawList) {
    return rawList.map((type) {
      return {
        'name': type['group_name'],
        'list': type['v_item'].map((item) {
          return {
            'parent_id': type['group_id'],
            'parent_name': type['group_name'],
            'id': item['group_id'],
            'name': item['name'],
            'source': 'tx',
          };
        })
      };
    }).toList();
  }

  static Future getTag() async {
    try {
      Response res = await Dio().request(tagsUrl, options: Options(
        responseType: ResponseType.bytes,
      ));
      String str = const Utf8Decoder().convert(res.data);
      Map tagMap = json.decode(str);
      return filterTagInfo(tagMap['tags']['data']['v_group']);
    } catch (e, s) {
      Logger.error('$e $s');
    }
  }

  static Future getHotTag() async {
    try {
      var res = await HttpCore.getInstance().get(hotTagUrl);
      return filterInfoHotTag(res);
    } catch (e, s) {
      Logger.error('$e $s');
    }
  }

  static List filterInfoHotTag(String html) {
    Iterable matches = hotTagHtmlRegExp.allMatches(html);
    List hotTags = [];
    matches.forEach((tagHtml) {
      var result = hotTagRegExp.firstMatch(tagHtml.group(0));
      hotTags.add({
        'id': result?.group(1),
        'name': result?.group(2),
        'source': 'tx',
      });
    });
    return hotTags;
  }

  static Future getTags() async {
    var res = await Future.wait([getTag(), getHotTag()]);
    return {
      'tags': res[0],
      'hotTags': res[1],
      'source': 'tx',
    };
  }

  static getList() {}
}
