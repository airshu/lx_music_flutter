import 'dart:convert';
import 'dart:math';

import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/app_util.dart';
import 'package:lx_music_flutter/models/music_item.dart';
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

  static Future<MusicModel> getListDetailBySpecialId(String id, int page) async {
    var res = await HttpCore.getInstance().get(getSongListDetailurl(id));
    Iterable<RegExpMatch> listData = listDataRegExp.allMatches(res);
    Iterable<RegExpMatch> listInfo = listInfoRegExp.allMatches(res);
    if (listData.isEmpty) {
      return getListDetailBySpecialId(id, page);
    }

    String listDataStr = listData.elementAt(0).group(0) ?? '';
    List musicInfoList = jsonDecode(listDataStr.substring(14, listDataStr.length - 1));

    List<MusicItem> list = await getMusicInfos(musicInfoList);
    String name = '';
    String pic = '';
    if (listInfo.isNotEmpty) {
      String listInfoStr = listInfo.elementAt(0).group(0) ?? '';
      List infoList = listInfoStr.split('\n');
      for (var info in infoList) {
        if (info.contains('name')) {
          name = info.split('"')[1];
        } else if (info.contains('pic')) {
          pic = info.split('"')[1];
        }
      }
    }
    String desc = parseHtmlDesc(res) ?? '';
    return MusicModel(
        list: list,
        limit: 100000,
        total: list.length,
        source: AppConst.sourceKG,
        page: 1,
        info: DetailInfo(
          author: '',
          name: name,
          imgUrl: pic,
          desc: desc,
        ));
  }

  static Future<List<MusicItem>> getMusicInfos(list) async {
    List duDuplicationList = deDuplication(list);
    List list1 = duDuplicationList
        .map((item) => ({
              'hash': item['hash'],
            }))
        .toList();
    List list2 = await createTask(list1);
    List list3 = list2.expand((element) => element).toList();
    List list4 = list3.expand((element) => element).toList();
    return filterData2(list4);
  }

  static List<MusicItem> filterData2(List<dynamic> rawList) {
    Set<String> ids = {};
    List<MusicItem> list = [];
    for (var item in rawList) {
      if (item == null) continue;
      if (ids.contains(item['audio_info']['audio_id'])) continue;
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
      list.add(MusicItem(
        name: AppUtil.decodeName(item['songname']),
        source: AppConst.sourceKG,
        img: '',
        singer: AppUtil.decodeName(item['author_name']),
        albumName: AppUtil.decodeName(item['album_name']),
        albumId: item['album_info']['album_id'],
        qualityList: types,
        interval: AppUtil.formatPlayTime(int.parse(item['audio_info']['timelength']) ~/ 1000),
        qualityMap: _types,
        songmid: item['audio_info']['audio_id'],
        urlMap: {},
      ));
      // list.add({
      //   'singer': AppUtil.decodeName(item['author_name']),
      //   'name': AppUtil.decodeName(item['songname']),
      //   'albumName': AppUtil.decodeName(item['album_info']['album_name']),
      //   'albumId': item['album_info']['album_id'],
      //   'songmid': item['audio_info']['audio_id'],
      //   'source': 'kg',
      //   'interval': AppUtil.formatPlayTime(int.parse(item['audio_info']['timelength']) ~/ 1000),
      //   'img': null,
      //   'lrc': null,
      //   'hash': item['audio_info']['hash'],
      //   'otherSource': null,
      //   'types': types,
      //   '_types': _types,
      //   'typeUrl': {},
      // });
    }
    return list;
  }

  static List deDuplication(List datas) {
    var ids = <dynamic>{};
    return datas.where((element) {
      if (ids.contains(element['hash'])) return false;
      ids.add(element['hash']);
      return true;
    }).toList();
  }

  static Future createTask(hashs) async {
    var data = {
      'area_code': '1',
      'show_privilege': 1,
      'show_album_info': '1',
      'is_publish': '',
      'appid': 1005,
      'clientver': 11451,
      'mid': '1',
      'dfid': '-',
      'clienttime': DateTime.now().millisecondsSinceEpoch,
      'key': 'OIlwieks28dk2k092lksi2UIkp',
      'fields': 'album_info,author_name,audio_info,ori_audio_name,base,songname',
    };
    List list = hashs;
    List tasks = [];
    while (list.isNotEmpty) {
      data['data'] = list.sublist(0, min(100, list.length));
      tasks.add(data);
      if (list.length < 100) break;
      list = list.sublist(100);
    }

    String url = 'http://gateway.kugou.com/v2/album_audio/audio';

    List results = [];
    for (var task in tasks) {
      var headers = {
        'KG-THash': '13a3164',
        'KG-RC': '1',
        'KG-Fake': '0',
        'KG-RF': '00869891',
        'User-Agent': 'Android712-AndroidPhone-11451-376-0-FeeCacheUpdate-wifi',
        'x-router': 'kmr.service.kugou.com',
      };
      var res = await HttpCore.getInstance().post(url, data: task, headers: headers);
      results.add(res['data']);
    }

    return results;
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

  static Future<MusicListModel> getList([String? sortId, String? tagId, int page = 0]) async {
    List<MusicListItem> tasks = await getSongList(sortId, tagId, page);
    MusicListModel? info;
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

    info?.list = tasks;
    return info!;
  }

  static Future<List<MusicListItem>> getSongList([String? sortId, String? tagId, int page = 0]) async {
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

  static List<MusicListItem> filterList(List rawList) {
    return rawList.map((item) {
      return MusicListItem(
        name: item['specialname'],
        source: AppConst.sourceKG,
        img: item['img'] ?? item['imgurl'],
        playCount: item['total_play_count'] ?? AppUtil.formatPlayCount(item['play_count']),
        id: 'id_${item['specialid']}',
        author: item['nickname'],
        total: item['songcount'],
        grade: '${item['grade']}',
        desc: item['intro'],
        time: AppUtil.dateFormat(item['publish_time'] ?? item['publishtime'], 'Y-M-D'),
      );
      // return {
      //   'play_count': item['total_play_count'] ?? AppUtil.formatPlayCount(item['play_count']),
      //   'id': 'id_${item['specialid']}',
      //   'author': item['nickname'],
      //   'name': item['specialname'],
      //   'time': AppUtil.dateFormat(item['publish_time'] ?? item['publishtime'], 'Y-M-D'),
      //   'img': item['img'] ?? item['imgurl'],
      //   'total': item['songcount'],
      //   'grade': item['grade'],
      //   'desc': item['intro'],
      //   'source': 'kg',
      // };
    }).toList();
  }

  static Future<MusicListModel?> getListInfo(String tagId) async {
    String url = getInfoUrl(tagId);
    var res = await HttpCore.getInstance().get(url);
    if (res['status'] == 1) {
      return MusicListModel(
          list: [], limit: res['data']['params']['pagesize'], total: res['data']['params']['total'], source: AppConst.sourceKG);
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

  static final listDetailLink = RegExp(r'^.+\/(\d+)\.html(?:\?.*|&.*$|#.*$|$)');

  static const int listDetailLimit = 10000;

  static Future<MusicModel?> getListDetail(String id, int page) async {
    if (id.contains('special/single/')) {
      id = id.replaceAllMapped(listDetailLink, (match) => match.group(1)!);
    } else if (RegExp(r'https?:').hasMatch(id)) {
      // fix https://www.kugou.com/songlist/xxx/?uid=xxx&chl=qq_client&cover=http%3A%2F%2Fimge.kugou.com%xxx.jpg&iszlist=1
      return getUserListDetail(id.replaceFirst(RegExp(r'^.*?http'), 'http'), page);
    } else if (RegExp(r'^\d+$').hasMatch(id)) {
      return getUserListDetailByCode(id);
    } else if (id.startsWith('id_')) {
      id = id.replaceFirst('id_', '');
    }
    // if ((/[?&:/]/.test(id))) id = id.replace(this.regExps.listDetailLink, '$1')

    return getListDetailBySpecialId(id, page);
  }

  static Future<MusicModel?> getUserListDetail(String link, int page) async {
    if (link.contains('#')) {
      link.replaceAll(RegExp(r'#.*$'), '');
    }
    if (link.contains('global_collection_id')) {
      String replacedLink = link.replaceAllMapped(
        RegExp(r'^.*?global_collection_id=(\w+)(?:&.*$|#.*$|$)'),
        (match) => match.group(1)!,
      );
      return getUserListDetail2(replacedLink);
    }
    if (link.contains('chain=')) {
      String replacedLink = link.replaceAllMapped(
        RegExp(r'^.*?chain=(\w+)(?:&.*$|#.*$|$)'),
        (match) => match.group(1)!,
      );
      return getUserListDetail3(replacedLink, page);
    }
    if (link.contains('.html')) {
      if (link.contains('zlist.html')) {
        link = link.replaceAll(RegExp(r'^(.*)zlist\.html'), 'https://m3ws.kugou.com/zlist/list');
        if (link.contains('pagesize')) {
          link = link.replaceAll('pagesize=30', 'pagesize=$listDetailLimit').replaceAll('page=1', 'page=$page');
        } else {
          link = '$link&pagesize=$listDetailLimit&page=$page';
        }
      } else if (!link.contains('song.html')) {
        String replacedLink = link.replaceAllMapped(
          RegExp(r'.+\/(\w+).html(?:\?.*|&.*$|#.*$|$)'),
          (match) => match.group(1)!,
        );
        return getUserListDetail3(replacedLink, page);
      }
    }

    var res = await HttpCore.getInstance().get(link, headers: {
      'User-Agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1',
      'Referer': link,
    });
    String location = res['location'];
    if (location.split('?')[0] != link.split('?')[0]) {
      if (location.contains('global_collection_id')) {
        String replacedLink = link.replaceAllMapped(
          RegExp(r'^.*?global_collection_id=(\w+)(?:&.*$|#.*$|$)'),
          (match) => match.group(1)!,
        );
        return getUserListDetail2(replacedLink);
      }
      if (location.contains('chain=')) {
        String replacedLink = link.replaceAllMapped(
          RegExp(r'^.*?chain=(\w+)(?:&.*$|#.*$|$)'),
          (match) => match.group(1)!,
        );

        return getUserListDetail3(replacedLink, page);
      }
      if (location.contains('.html')) {
        if (link.contains('zlist.html')) {
          link = link.replaceAll(RegExp(r'^(.*)zlist\.html'), 'https://m3ws.kugou.com/zlist/list');
          if (link.contains('pagesize')) {
            link = link.replaceAll('pagesize=30', 'pagesize=$listDetailLimit').replaceAll('page=1', 'page=$page');
          } else {
            link = '$link&pagesize=$listDetailLimit&page=$page';
          }
        } else if (!link.contains('song.html')) {
          String replacedLink = link.replaceAllMapped(
            RegExp(r'.+\/(\w+).html(?:\?.*|&.*$|#.*$|$)'),
            (match) => match.group(1)!,
          );
          return getUserListDetail3(replacedLink, page);
        }
      }
    }

    if (res['body'] is String) {
      String replacedBody = res['body'].replaceAllMapped(
        RegExp(r'^[\s\S]+?"global_collection_id":"(\w+)"[\s\S]+?$'),
        (match) => match.group(1)!,
      );
      return getUserListDetail2(replacedBody);
    }

    return getuserListDetailByLink(res['body'], link);
  }

  static Future<MusicModel> getUserListDetailByCode(String id) async {
    String url = 'http://t.kugou.com/command/';
    var headers = {
      'KG-RC': 1,
      'KG-THash': 'network_super_call.cpp:3676261689:379',
      'User-Agent': '',
    };
    var body = {
      'appid': 1001,
      'clientver': 9020,
      'mid': '21511157a05844bd085308bc76ef3343',
      'clienttime': 640612895,
      'key': '36164c4015e704673c588ee202b9ecb8',
      'data': id
    };
    dynamic songList;
    var songInfo = await HttpCore.getInstance().post(url, headers: headers, data: body);
    var info = songInfo['info'];
    switch (info['type']) {
      case 2:
        if (info['global_collection_id'] == null) {
          return getListDetailBySpecialId(info['id'], 1);
          break;
        }
      default:
        break;
    }
    if (info['global_collection_id'] != null) {
      return getUserListDetail2(info['global_collection_id']);
    }
    if (info['userid'] != null) {
      String _url = 'http://www2.kugou.kugou.com/apps/kucodeAndShare/app/';
      var headers = {
        'KG-RC': 1,
        'KG-THash': 'network_super_call.cpp:3676261689:379',
        'User-Agent': '',
      };
      var body = {
        'appid': 1001,
        'clientver': 9020,
        'mid': '21511157a05844bd085308bc76ef3343',
        'clienttime': 640612895,
        'key': '36164c4015e704673c588ee202b9ecb8',
        'data': {
          'id': info['id'],
          'type': 3,
          'userid': info['userid'],
          'collect_type': 0,
          'page': 1,
          'pagesize': info['count'],
        }
      };
      songList = await HttpCore.getInstance().post(_url, headers: headers, data: body);
    }
    List<MusicItem> list = await getMusicInfos(songList ?? songInfo['list']);
    return MusicModel(
      list: list,
      page: 1,
      limit: info['count'],
      total: list.length,
      source: 'kg',
      info: DetailInfo(
        name: info['name'],
        imgUrl: (info['img_size'] && info['img_size'].replace('{size}', 240)) ?? info['img'],
        // desc: body.result.info.list_desc,
        author: info['username'],
        // play_count: formatPlayCount(info.count),
      ),
    );
  }

  static Future<MusicModel> getuserListDetailByLink(info, String link) async {
    var listInfo = info['0'];
    var total = listInfo['count'];
    List tasks = [];
    int page = 0;
    while (total) {
      var limit = total > 90 ? 90 : total;
      total -= limit;
      page += 1;
      String url = link
          .replaceFirstMapped(RegExp(r"pagesize=\d+"), (match) => 'pagesize=$limit')
          .replaceFirstMapped(RegExp(r"page=\d+"), (match) => 'page=$page');
      var res = await HttpCore.getInstance().get(url, headers: {
        'User-Agent':
            'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1',
        'Referer': link,
      });

      tasks.add(res['list']['info']);
    }

    var result = await getMusicInfos(tasks);

    return MusicModel(
      list: result,
      page: page,
      limit: listDetailLimit,
      total: total,
      source: AppConst.sourceKG,
      info: DetailInfo(
        name: listInfo['name'],
        imgUrl: listInfo['pic'] != null ? listInfo['pic'].replace('{size}', 240) : '',
        desc: '',
        //body.result.info.list_desc,
        author: listInfo['list_create_username'],
        playCount: '',
        // play_count: formatPlayCount(listInfo.count),
      ),
    );
    // return {
    //   'list': result,
    //   'page': page,
    //   'limit': listDetailLimit,
    //   'total': result.length,
    //   'source': 'kg',
    //   'info': DetailInfo(
    //     name: listInfo['name'],
    //     imgUrl: listInfo['pic'] != null ? listInfo['pic'].replace('{size}', 240) : '',
    //     desc: '',
    //     //body.result.info.list_desc,
    //     author: listInfo['list_create_username'],
    //     playCount: '',
    //     // play_count: formatPlayCount(listInfo.count),
    //   ),
    // };
  }

  static Future<MusicModel> getUserListDetail2(String id) async {
    if (id.length > 1000) {
      throw 'get list error';
    }
    var params =
        'appid=1058&specialid=0&global_specialid=$id&format=jsonp&srcappid=2919&clientver=20000&clienttime=1586163242519&mid=1586163242519&uuid=1586163242519&dfid=-';

    var headers = {
      'mid': '1586163242519',
      'Referer': 'https://m3ws.kugou.com/share/index.php',
      'User-Agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1',
      'dfid': '-',
      'clienttime': '1586163242519',
    };
    String url = 'https://mobiles.kugou.com/api/v5/special/info_v2?${params}&signature=${signatureParams(params, 5)}';
    var info = await HttpCore.getInstance().get(url, headers: headers);
    var songInfo = await createGetListDetail2Task(id, info['songcount']);
    List<MusicItem> list = await getMusicInfos(songInfo);
    return MusicModel(
      list: list,
      page: 1,
      limit: listDetailLimit,
      total: list.length,
      source: AppConst.sourceKG,
      info: DetailInfo(
        name: info['specialname'],
        imgUrl: info['imgurl'] != null ? info['imgurl'].replace('{size}', 240) : '',
        author: info['nickname'],
        desc: info['intro'],
        playCount: AppUtil.formatPlayCount(info['playcount']),
        // desc: body.result.info.list_desc,
      ),
    );
    // return {
    //   'list': list,
    //   'page': 1,
    //   'limit': listDetailLimit,
    //   'total': list.length,
    //   'source': 'kg',
    //   'info': DetailInfo(
    //     name: info['specialname'],
    //     imgUrl: info['imgurl'] != null ? info['imgurl'].replace('{size}', 240) : '',
    //     author: info['nickname'],
    //     desc: info['intro'],
    //     playCount: AppUtil.formatPlayCount(info['playcount']),
    //     // desc: body.result.info.list_desc,
    //   ),
    // };
  }

  static Future createGetListDetail2Task(String id, int total) async {
    var tasks = [];
    var page = 0;
    while (total > 0) {
      var limit = 300;
      if (total > 300) {
        limit = 300;
      } else {
        limit = total;
      }
      total -= limit;
      page += 1;
      var params =
          "appid=1058&global_specialid=$id&specialid=0&plat=0&version=8000&page=$page&pagesize=$limit&srcappid=2919&clientver=20000&clienttime=1586163263991&mid=1586163263991&uuid=1586163263991&dfid=-";

      String url = "https://mobiles.kugou.com/api/v5/special/song_v2?" + params + "&signature=" + signatureParams(params, 5).toString();
      var headers = {
        "mid": "1586163263991",
        "Referer": "https://m3ws.kugou.com/share/index.php",
        "User-Agent":
            "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1",
        "dfid": "-",
        "clienttime": "1586163263991",
      };
      var res = await HttpCore.getInstance().get(url, headers: headers);
      tasks.add(res['info']);
    }
    return tasks;
  }

  static Future<MusicModel> getUserListDetail3(String chain, int page) async {
    String url = 'http://m.kugou.com/schain/transfer?pagesize=${listDetailLimit}&chain=${chain}&su=1&page=${page}&n=0.7928855356604456';
    var headers = {
      'User-Agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1',
    };

    var songInfo = await HttpCore.getInstance().get(url, headers: headers);
    if (songInfo['list'] == null) {
      if (songInfo['global_collection_id'] != null) {
        return getUserListDetail2(songInfo['global_collection_id']);
      } else {
        try {
          return getUserListDetail4(songInfo, chain, page);
        } catch (e, s) {
          return getUserListDetail5(chain);
        }
      }
    }

    var list = await getMusicInfos(songInfo['list']);
    return MusicModel(
      list: list,
      page: 1,
      limit: listDetailLimit,
      total: list.length,
      source: AppConst.sourceKG,
      info: DetailInfo(
        name: songInfo['info']['name'],
        imgUrl: songInfo['info']['img'],
        // desc: body.result.info.list_desc,
        author: songInfo['info']['username'],
        // play_count: formatPlayCount(info.count),
      ),
    );
    // return {
    //   'list': list,
    //   'page': 1,
    //   'limit': listDetailLimit,
    //   'total': list.length,
    //   'source': 'kg',
    //   'info': DetailInfo(
    //     name: songInfo['info']['name'],
    //     imgUrl: songInfo['info']['img'],
    //     // desc: body.result.info.list_desc,
    //     author: songInfo['info']['username'],
    //     // play_count: formatPlayCount(info.count),
    //   ),
    // };
  }

  static Future<MusicModel> getUserListDetail4(songInfo, String chain, int page) async {
    var limit = 100;
    var listInfo = await getListInfoByChain(chain);
    var list = await getUserListDetailById(songInfo.id, page, limit);
    return MusicModel(
      list: list,
      page: page,
      limit: limit,
      total: list.length ?? 0,
      source: AppConst.sourceKG,
      info: DetailInfo(
        name: listInfo['specialname'],
        imgUrl: listInfo['imgurl'] != null ? listInfo['imgurl'].replace('{size}', 240) : '',
        // desc: body.result.info.list_desc,
        author: listInfo['nickname'],
        // play_count: formatPlayCount(info.count),
      ),
    );
    // return {
    //   'list': list ?? [],
    //   'page': page,
    //   'limit': limit,
    //   'total': list.length ?? 0,
    //   'source': 'kg',
    //   'info': DetailInfo(
    //     name: listInfo['specialname'],
    //     imgUrl: listInfo['imgurl'] != null ? listInfo['imgurl'].replace('{size}', 240) : '',
    //     // desc: body.result.info.list_desc,
    //     author: listInfo['nickname'],
    //     // play_count: formatPlayCount(info.count),
    //   ),
    // };
  }

  static Future getListInfoByChain(String chain) async {
    String url = 'https://m.kugou.com/share/?chain=${chain}&id=${chain}';
    var headers = {
      'User-Agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1',
    };
    var res = await HttpCore.getInstance().get(url, headers: headers);

    var result = RegExp(r'var\sphpParam\s=\s({.+?});').firstMatch(res['body']);
    if (result != null) {
      result = json.decode(result.group(1)!);
    }
    return result;
  }

  static Future getUserListDetailById(id, int page, int limit) async {
    var signature = await handleSignature(id, page, limit);
    String url =
        'https://pubsongscdn.kugou.com/v2/get_other_list_file?srcappid=2919&clientver=20000&appid=1058&type=0&module=playlist&page=${page}&pagesize=${limit}&specialid=${id}&signature=${signature}';
    var headers = {
      'Referer': 'https://m3ws.kugou.com/share/index.php',
      'User-Agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1',
      'dfid': '-',
    };
    var info = await HttpCore.getInstance().get(url, headers: headers);
    var result = getMusicInfos(info['info']);
    return result;
  }

  static Future handleSignature(id, int page, int limit) async {}

  static signatureParams(String params, int i) {}

  static Future<MusicModel> getUserListDetail5(String chain) async {
    var listInfo = await getListInfoByChain(chain);
    List<MusicItem>? list = await getUserListDetailByPcChain(chain);
    return MusicModel(
      list: list ?? [],
      page: 1,
      limit: listDetailLimit,
      total: list?.length ?? 0,
      source: AppConst.sourceKG,
      info: DetailInfo(
        name: listInfo['specialname'],
        imgUrl: listInfo['imgurl'] != null ? listInfo['imgurl'].replace('{size}', 240) : '',
        // desc: body.result.info.list_desc,
        author: listInfo['nickname'],
        // play_count: formatPlayCount(info.count),
      ),
    );
    // return {
    //   'list': list ?? [],
    //   'page': 1,
    //   'limit': listDetailLimit,
    //   'total': list?.length ?? 0,
    //   'source': 'kg',
    //   'info': DetailInfo(
    //     name: listInfo['specialname'],
    //     imgUrl: listInfo['imgurl'] != null ? listInfo['imgurl'].replace('{size}', 240) : '',
    //     // desc: body.result.info.list_desc,
    //     author: listInfo['nickname'],
    //     // play_count: formatPlayCount(info.count),
    //   ),
    // };
  }

  static Future<List<MusicItem>?> getUserListDetailByPcChain(String chain) async {
    String url = 'http://www.kugou.com/share/${chain}.html';
    var headers = {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36',
    };
    var res = await HttpCore.getInstance().get(url, headers: headers);

    RegExp regExp = RegExp(r'var\sdataFromSmarty\s=\s(\[.+?\])');
    var result = regExp.firstMatch(res['body'] as String)?.group(1);
    if (result != null) {
      return await getMusicInfos(result);
    }
  }

  /// 根据关键字搜索歌单
  static Future<MusicListModel?> search(String text, [int page = 1, int limit = 10]) async {
    String url =
        'http://msearchretry.kugou.com/api/v3/search/special?keyword=${Uri.encodeComponent(text)}&page=${page}&pagesize=${limit}&showtype=10&filter=0&version=7910&sver=2';
    var res = await HttpCore.getInstance().get(url);
    if (res['errcode'] == 0) {
      List<MusicListItem> list = [];
      for (var item in res['data']['info']) {
        list.add(MusicListItem(
          name: item['specialname'],
          source: AppConst.nameKG,
          img: item['imgurl'],
          playCount: AppUtil.formatPlayCount(item['playcount']),
          id: 'id_${item['specialid']}',
          author: item['nickname'],
          time: AppUtil.dateFormat(item['publishtime'], 'Y-M-D'),
          grade: item['grade'],
          total: '${item['songcount']}',
        ));
      }
      return MusicListModel(list: list, limit: limit, total: res['data']['total'], source: AppConst.nameKG);
    }
  }
}
