import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:lx_music_flutter/app/app_util.dart';
import 'package:lx_music_flutter/models/song_list.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';

class TXSongList {
  static const int limit_list = 36;
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
    List list = [];
    for (var type in rawList) {
      list.add({
        'name': type['group_name'],
        'list': type['v_item'].map((item) {
          return {
            'parent_id': type['group_id'],
            'parent_name': type['group_name'],
            'id': item['id'],
            'name': item['name'],
            'source': 'tx',
          };
        }).toList(),
      });
    }
    return list;
  }

  static Future getTag() async {
    try {
      Response res = await Dio().request(tagsUrl,
          options: Options(
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

  static getListUrl([sortId, id, page]) {
    if (id != null) {
      Map data = {
        'comm': {'ct': 20, 'cv': 1602},
        'playlist': {
          'method': 'get_category_content',
          'param': {
            'titleid': id,
            'caller': '0',
            'category_id': id,
            'size': limit_list,
            'page': page - 1,
            'use_page': 1,
          },
          'module': 'playlist.PlayListCategoryServer',
        },
      };
      var _data = Uri.encodeComponent(json.encode(data));
      return 'https://u.y.qq.com/cgi-bin/musicu.fcg?loginUin=0&hostUin=0&format=json&inCharset=utf-8&outCharset=utf-8&notice=0&platform=wk_v15.json&needNewCode=0&data=${_data}';
    }
    Map data = {
      'comm': {'ct': 20, 'cv': 1602},
      'playlist': {
        'method': 'get_playlist_by_tag',
        'param': {
          'id': 10000000,
          'sin': limit_list * (page - 1),
          'size': limit_list,
          'order': 'sortId',
          'cur_page': page,
        },
        'module': 'playlist.PlayListPlazaServer',
      },
    };
    var _data = Uri.encodeComponent(json.encode(data));

    return 'https://u.y.qq.com/cgi-bin/musicu.fcg?loginUin=0&hostUin=0&format=json&inCharset=utf-8&outCharset=utf-8&notice=0&platform=wk_v15.json&needNewCode=0&data=$_data';
  }

  static Future getList([String? sortId, String? tagId, int page = 0]) async {
    String url = getListUrl(sortId, tagId, page);
    try {
      Response res = await Dio().request(url,
          options: Options(
            responseType: ResponseType.bytes,
          ));
      String str = const Utf8Decoder().convert(res.data);
      Map info = json.decode(str);
      if (tagId != null) {
        return filterList2(info['playlist']['data']['content'], page);
      }
      return filterList(info['playlist']['data'], page);
    } catch(e, s) {
      Logger.error('$e  $s');
    }
  }

  static Map filterList2(content, int page) {
    List list = content['v_item'].map((basic) {
      return {
        'play_count': AppUtil.formatPlayCount(basic['play_cnt'] ?? '0'),
        'id': basic['id'],
        'author': basic['creator']['nick'],
        'name': basic['title'],
        'img': basic['cover']?['medium_url'] ?? basic['cover']?['default_url'],
        'desc': AppUtil.decodeName(basic['desc']).replaceAll('<br/>', '\n'),
        'source': 'tx',
      };
    }).toList();
    return {
      'list': list,
      'total': content['total_cnt'],
      'page': page,
      'limit': limit_list,
      'source': 'tx',
    };
  }

  static Map filterList(data, int page) {
    List list = data['v_playlist'].map((item) {
      return {
        'play_count': AppUtil.formatPlayCount(item['access_num'] ?? '0'),
        'id': item['tid'],
        'author': item['creator_info']['nick'],
        'name': item['title'],
        'time': item['modify_time'] ?? AppUtil.dateFormat(item['modify_time'] * 1000, 'Y-M-D'),
        'img': item['cover_url_medium'],
        'total': item['song_ids']?['length'],
        'desc': item['desc'],
        'source': 'tx',
      };
    }).toList();

    return {
      'list': list,
      'total': data['total'],
      'page': page,
      'limit': limit_list,
      'source': 'tx',
    };
  }
}
