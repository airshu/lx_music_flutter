import 'package:lx_music_flutter/app/app_util.dart';
import 'package:lx_music_flutter/models/song_list.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';

class KGSongList {
  static List<SortItem> sortList = [
    SortItem(name: '推荐', tid: 'recommend', id: '5', isSelect: true),
    SortItem(name: '最热', tid: 'hot', id: '6'),
    SortItem(name: '最新', tid: 'new', id: '7'),
    SortItem(name: '热藏', tid: 'hot_collect', id: '3'),
    SortItem(name: '飙升', tid: 'rise', id: '8'),
  ];

  static RegExp listDataRegExp = RegExp(r'global\.data = (\[.+\]);');
  static RegExp listInfoRegExp = RegExp(r'global = {[\s\S]+?name: "(.+)"[\s\S]+?pic: "(.+)"[\s\S]+?};');
  static RegExp listDetailLinkRegExp = RegExp(r'^.+\/(\d+)\.html(?:\?.*|&.*$|#.*$|$)');

  static String getInfoUrl(dynamic tagId) {
    return tagId != null
        ? 'http://www2.kugou.kugou.com/yueku/v9/special/getSpecial?is_smarty=1&cdn=cdn&t=5&c=${tagId}'
        : 'http://www2.kugou.kugou.com/yueku/v9/special/getSpecial?is_smarty=1&';
  }

  static String? parseHtmlDesc(String html) {
    const prefix = '<div class="pc_specail_text pc_singer_tab_content" id="specailIntroduceWrap">';
    int index = html.indexOf(prefix);
    if (index < 0) {
      return null;
    }
    String afterStr = html.substring(index + prefix.length);
    index = afterStr.indexOf('</div>');
    if (index < 0) {
      return null;
    }
    return AppUtil.decodeName(afterStr.substring(0, index));
  }

  static Future getListDetailBySpecialId(String id, int page) async {
    var res = await HttpCore.getInstance().get(getSongListDetailurl(id));
    dynamic listData = listDataRegExp.allMatches(res);
    dynamic listInfo = listInfoRegExp.allMatches(res);
    if (listData != null) {
      return getListDetailBySpecialId(id, page);
    }
    var list = await getMusicInfos(listData[1]);
    String name = '';
    String pic = '';
    if (listInfo != null) {
      name = listInfo[1];
      pic = listInfo[2];
    }
    String desc = parseHtmlDesc(res) ?? '';
    return {
      'list': list,
      'page': 1,
      'limit': 100000,
      'total': list.length,
      'source': 'kg',
      'info': {
        'name': name,
        'img': 'pic',
        'desc': desc,
      },
    };
  }

  static Future getMusicInfos(list) async {
    return await filterData2(await Future.wait(createTask(deDuplication(list).map((item) => ({
          'hash': item['hash'],
        })))).then((value) {
      return value.expand((element) => element).toList();
    }));
  }

  static List<Map<String, dynamic>> filterData2(List<dynamic> rawList) {
    // print(rawList);
    Set<String> ids = {};
    List<Map<String, dynamic>> list = [];
    rawList.forEach((item) {
      if (item == null) return;
      if (ids.contains(item['audio_info']['audio_id'])) return;
      ids.add(item['audio_info']['audio_id']);
      Map<String, dynamic> _types = {};
      List<Map<String, dynamic>> types = [];
      if (item['audio_info']['filesize'] != '0') {
        var size = AppUtil.sizeFormate(int.parse(item['audio_info']['filesize']));
        types.add({
          'type': '128k',
          'size': size,
          'hash': item['audio_info']['hash'],
        });
        _types['128k'] = {
          'size': size,
          'hash': item['audio_info']['hash'],
        };
      }
      if (item['audio_info']['filesize_320'] != '0') {
        var size = AppUtil.sizeFormate(int.parse(item['audio_info']['filesize_320']));
        types.add({
          'type': '320k',
          'size': size,
          'hash': item['audio_info']['hash_320'],
        });
        _types['320k'] = {
          'size': size,
          'hash': item['audio_info']['hash_320'],
        };
      }
      if (item['audio_info']['filesize_flac'] != '0') {
        var size = AppUtil.sizeFormate(int.parse(item['audio_info']['filesize_flac']));
        types.add({
          'type': 'flac',
          'size': size,
          'hash': item['audio_info']['hash_flac'],
        });
        _types['flac'] = {
          'size': size,
          'hash': item['audio_info']['hash_flac'],
        };
      }
      if (item['audio_info']['filesize_high'] != '0') {
        var size = AppUtil.sizeFormate(int.parse(item['audio_info']['filesize_high']));
        types.add({
          'type': 'flac24bit',
          'size': size,
          'hash': item['audio_info']['hash_high'],
        });
        _types['flac24bit'] = {
          'size': size,
          'hash': item['audio_info']['hash_high'],
        };
      }
      list.add({
        'singer': AppUtil.decodeName(item['author_name']),
        'name': AppUtil.decodeName(item['songname']),
        'albumName': AppUtil.decodeName(item['album_info']['album_name']),
        'albumId': item['album_info']['album_id'],
        'songmid': item['audio_info']['audio_id'],
        'source': 'kg',
        'interval': AppUtil.formatPlayTime(int.parse(item['audio_info']['timelength']) ~/ 1000),
        'img': null,
        'lrc': null,
        'hash': item['audio_info']['hash'],
        'otherSource': null,
        'types': types,
        '_types': _types,
        'typeUrl': {},
      });
    });
    return list;
  }

  static List<Map<String, dynamic>> deDuplication(List<Map<String, dynamic>> datas) {
    var ids = <dynamic>{};
    return datas.where((element) {
      if (ids.contains(element['hash'])) return false;
      ids.add(element['hash']);
      return true;
    }).toList();
  }

  static createTask(hashs) {
    var data = {
      'area_code': '1',
      'show_privilege': 1,
      'show_album_info': '1',
      'is_publish': '',
      'clientver': 11451,
    };
  }

  static Future getTags() async {
    var res = await HttpCore.getInstance().get(getInfoUrl(null));
    if (res['status'] == 1) {
      return {
        'hotTags': filterInfoHotTag(res['data']['hotTag']),
        'tags': filterTagInfo(res['data']['tagids']),
        'source': 'kg',
      };
    }
  }

  static List filterTagInfo(Map rawData) {
    final result = [];

    for (MapEntry entry in rawData.entries) {
      // for (final name in rawData) {
      String name = entry.key;
      result.add({
        'name': name,
        'list': rawData[name]['data'].map((tag) => ({
              'parent_id': tag['parent_id'],
              'parent_name': tag['pname'],
              'id': tag['id'],
              'name': tag['name'],
              'source': 'kg',
            })),
      });
    }
    return result;
  }

  static filterInfoHotTag(dynamic rawData) {
    List result = [];
    if (rawData['status'] != 1) {
      return result;
    }
    for (MapEntry entry in (rawData['data'] as Map).entries) {
      String key = entry.key;
      // for (var key in rawData['data']) {
      var tag = rawData['data'][key];
      result.add({
        'id': tag['special_id'],
        'name': tag['special_name'],
        'source': 'kg',
      });
    }
    return result;
  }

  static Map currentTagInfo = {
    'id': null,
    'info': null,
  };

  static Future getList([String? sortId, String? tagId, int page = 0]) async {
    var tasks = await getSongList(sortId, tagId, page);
    var info;
    if (currentTagInfo['id'] == tagId) {
      info = currentTagInfo['info'];
    } else {
      info = await getListInfo(tagId!);
      currentTagInfo['id'] = tagId;
      currentTagInfo['info'] = info;
    }
    if (tagId != null && page == 1 && sortId == sortList[0].id) {
      var recommendList = await getSongListRecommend();
      tasks.addAll(recommendList);
    }

    return {
      'list': tasks,
      ...info,
    };
  }




  static Future getSongList([String? sortId, String? tagId, int page = 0]) async {
    String url = getSonglistUrl(sortId, tagId, page);
    var res = await HttpCore.getInstance().get(url);
    return filterList(res['special_db']);
  }

  static String getSonglistUrl([String? sortId, String? tagId, int page = 0]) {
    return 'http://www2.kugou.kugou.com/yueku/v9/special/getSpecial?is_ajax=1&cdn=cdn&t=${sortId}&c=${tagId}&p=${page}';
  }

  static String getSongListDetailurl(String id) {
    return 'http://www2.kugou.kugou.com/yueku/v9/special/single/${id}-5-9999.html';
  }

  static List filterList(List rawList) {
    return rawList.map((item) {
      return {
        'play_count': item['total_play_count'] ?? AppUtil.formatPlayCount(item['play_count']),
        'id': 'id_${item['specialid']}',
        'author': item['nickname'],
        'name': item['specialname'],
        'time': AppUtil.dateFormat(item['publish_time'] ?? item['publishtime'], 'Y-M-D'),
      };
    }).toList();
  }

  static Future getListInfo(String tagId) async {
    String url = getInfoUrl(tagId);
    var res = await HttpCore.getInstance().get(url);
    if (res['status'] == 1) {
      return {
        'limit': res['data']['params']['pagesize'],
        'page': res['data']['params']['p'],
        'total': res['data']['params']['total'],
        'source': 'kg',
      };
    }
  }

  static Future getSongListRecommend() async {
    String url = 'http://everydayrec.service.kugou.com/guess_special_recommend';
    var res = await HttpCore.getInstance().post(
      url,
      headers: {
        'User-Agent': 'KuGou2012-8275-web_browser_event_handler',
      },
      data: {
        'appid': 1001,
        'clienttime': 1566798337219,
        'clientver': 8275,
        'key': 'f1f93580115bb106680d2375f8032d96',
        'mid': '21511157a05844bd085308bc76ef3343',
        'platform': 'pc',
        'userid': '262643156',
        'return_min': 6,
        'return_max': 15,
      },
    );
    return filterList(res['data']['special_list']);
  }

  static Future getListDetail(String id, int page) async {

  }
}
