import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/app_util.dart';
import 'package:lx_music_flutter/models/music_item.dart';
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
            'category_id': int.parse(id),
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
          'order': sortId,
          'cur_page': page,
        },
        'module': 'playlist.PlayListPlazaServer',
      },
    };
    var _data = Uri.encodeComponent(json.encode(data));

    return 'https://u.y.qq.com/cgi-bin/musicu.fcg?loginUin=0&hostUin=0&format=json&inCharset=utf-8&outCharset=utf-8&notice=0&platform=wk_v15.json&needNewCode=0&data=$_data';
  }

  static Future<MusicListModel?> getList([String? sortId, String? tagId, int page = 0]) async {
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
    } catch (e, s) {
      Logger.error('$e  $s');
    }
  }

  static MusicListModel filterList2(content, int page) {
    List<MusicListItem> list = [];
    for(var basic in content['v_item']) {
      basic = basic['basic'];
      list.add(MusicListItem(
        name: basic['title'],
        source: AppConst.sourceTX,
        img: basic['cover']?['medium_url'] ?? basic['cover']?['default_url'],
        playCount: AppUtil.formatPlayCount(basic['play_cnt'] ?? 0),
        id: basic['tid'].toString(),
        author: basic['creator']['nick'],
      ));
    }
      // return {
      //   'play_count': AppUtil.formatPlayCount(basic['play_cnt'] ?? 0),
      //   'id': basic['tid'].toString(),
      //   'author': basic['creator']['nick'],
      //   'name': basic['title'],
      //   'img': basic['cover']?['medium_url'] ?? basic['cover']?['default_url'],
      //   'desc': AppUtil.decodeName(basic['desc']).replaceAll('<br/>', '\n'),
      //   'source': 'tx',
      // };
    return MusicListModel(list: list, limit: limit_list, total: content['total_cnt'], source: AppConst.sourceTX);
    // return {
    //   'list': list,
    //   'total': content['total_cnt'],
    //   'page': page,
    //   'limit': limit_list,
    //   'source': 'tx',
    // };
  }

  static MusicListModel filterList(data, int page) {
    List<MusicListItem> list = data['v_playlist'].map((item) {
      return MusicListItem(
        name: item['title'],
        source: AppConst.sourceTX,
        img: item['cover_url_medium'],
        playCount: AppUtil.formatPlayCount(item['access_num'] ?? '0'),
        id: item['tid'],
        author: item['creator_info']['nick'],
        time: item['modify_time'] ?? AppUtil.dateFormat(item['modify_time'] * 1000, 'Y-M-D'),
        total: item['song_ids']?['length'],
        desc: item['desc'],
      );
      // return {
      //   'play_count': AppUtil.formatPlayCount(item['access_num'] ?? '0'),
      //   'id': item['tid'],
      //   'author': item['creator_info']['nick'],
      //   'name': item['title'],
      //   'time': item['modify_time'] ?? AppUtil.dateFormat(item['modify_time'] * 1000, 'Y-M-D'),
      //   'img': item['cover_url_medium'],
      //   'total': item['song_ids']?['length'],
      //   'desc': item['desc'],
      //   'source': 'tx',
      // };
    }).toList();

    return MusicListModel(list: list, limit: limit_list, total: data['total'], source: AppConst.sourceTX);
  }

  static Future<MusicModel?> getListDetail(String id, int page) async {
    id = await getListId(id);

    String url = getListDetailUrl(id);
    var headers = {
      'Origin': 'https://y.qq.com',
      'Referer': 'https://y.qq.com/n/yqq/playsquare/${id}.html',
    };

    var listDetail = await HttpCore.getInstance().get(url, headers: headers);
    var cdlist = listDetail['cdlist'][0];
    return MusicModel(
      list: filterListDetail(cdlist['songlist']),
      page: 1,
      limit: cdlist['songlist'].length + 1,
      total: cdlist['songlist'].length,
      source: 'tx',
      info: DetailInfo(
        name: cdlist['dissname'],
        imgUrl: cdlist['logo'],
        desc: AppUtil.decodeName(cdlist['desc']).replaceAll('<br>', '\n'),
        author: cdlist['nickname'],
        playCount: AppUtil.formatPlayCount(cdlist['visitnum']),
      ),
    );
  }

  static getListDetailUrl(id) {
    return 'https://c.y.qq.com/qzone/fcg-bin/fcg_ucc_getcdinfo_byids_cp.fcg?type=1&json=1&utf8=1&onlysong=0&new_format=1&disstid=${id}&loginUin=0&hostUin=0&format=json&inCharset=utf8&outCharset=utf-8&notice=0&platform=yqq.json&needNewCode=0';
  }

  static Future getListId(id) async {
    if (RegExp('[?&:/]').hasMatch(id)) {
      if (listDetailLinkRegExp.hasMatch(id)) {
        id = handleParseId(id);
      }
      Iterable<RegExpMatch> result = listDetailLinkRegExp.allMatches(id);
      if (result.isEmpty) {
        result = listDetailLink2RegExp.allMatches(id);
      }
      id = result.elementAt(0);
    }
    return id;
  }

  static Future handleParseId(link) async {
    var res = await HttpCore.getInstance().get(link);
    return res['url'];
  }

  static List<MusicItem> filterListDetail(List<dynamic> rawList) {
    return rawList.map((item) {
      List<Map<String, dynamic>> types = [];
      Map<String, dynamic> _types = {};
      if (item['file']['size_128mp3'] != null) {
        var size = AppUtil.sizeFormate(item['file']['size_128mp3']);
        types.add({'type': '128k', 'size': size});
        _types['128k'] = {'size': size};
      }

      if (item['file']['size_320mp3'] != null) {
        var size = AppUtil.sizeFormate(item['file']['size_320mp3']);
        types.add({'type': '320k', 'size': size});
        _types['320k'] = {'size': size};
      }

      if (item['file']['size_flac'] != null) {
        var size = AppUtil.sizeFormate(item['file']['size_flac']);
        types.add({'type': 'flac', 'size': size});
        _types['flac'] = {'size': size};
      }

      if (item['file']['size_hires'] != null) {
        var size = AppUtil.sizeFormate(item['file']['size_hires']);
        types.add({'type': 'flac24bit', 'size': size});
        _types['flac24bit'] = {'size': size};
      }

      return MusicItem(
        singer: AppUtil.formatSingerName(singers: item['singer']),
        name: item['title'],
        albumName: item['album']['name'],
        albumId: item['album']['mid'],
        songmid: item['mid'],
        source: 'tx',
        interval: AppUtil.formatPlayTime(item['interval']),
        // songId: item['id'],
        // albumMid: item['album']['mid'],
        // strMediaMid: item['file']['media_mid'],
        img: (item['album']['name'] == '' || item['album']['name'] == '空')
            ? (item['singer'] is Map && item['singer'].length > 0)
                ? 'https://y.gtimg.cn/music/photo_new/T001R500x500M000${item['singer'][0]['mid']}.jpg'
                : ''
            : 'https://y.gtimg.cn/music/photo_new/T002R500x500M000${item['album']['mid']}.jpg',
        lrc: null,
        otherSource: null,
        qualityList: types,
        qualityMap: _types,
        urlMap: {},
      );
    }).toList();
  }

  static Future<MusicListModel?> search(String text, [int page = 1, int limit = 10]) async {
    String url =
        'http://c.y.qq.com/soso/fcgi-bin/client_music_search_songlist?page_no=${page - 1}&num_per_page=${limit}&format=json&query=${Uri.encodeComponent(text)}&remoteplace=txt.yqq.playlist&inCharset=utf8&outCharset=utf-8';
    var headers = {
      'User-Agent': 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)',
      'Referer': 'http://y.qq.com/portal/search.html',
    };
    var res = await HttpCore.getInstance().get(url, headers: headers);
    if (res['code'] == 0) {
      List<MusicListItem> list = [];
      for (var item in res['data']['list']) {
        list.add(MusicListItem(
          name: item['dissname'],
          source: AppConst.sourceTX,
          img: item['imgurl'],
          playCount: AppUtil.formatPlayCount(item['listennum']),
          id: item['dissid'].toString(),
          author: item['creator']['name'],
          total: '${item['song_count']}',
        ));
      }
      return MusicListModel(list: list, limit: limit, total: res['data']['sum'], source: AppConst.sourceTX);
    }
  }
}
