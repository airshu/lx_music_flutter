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
    if (res['retCode'] == '100000') {
      return {
        'list': filterList(res['retMsg']['playlist']),
        'total': int.parse(res['retMsg']['countSize']),
        'limit': limit_list,
        'source': 'mg',
      };
    }
  }

  static String getSongListUrl([String? sortId, String? tagId, int page = 0]) {
    if (tagId == null) {
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

  static RegExp list = RegExp(r'<li><div class="thumb">.+?<\/li>', multiLine: true);
  static RegExp listInfo = RegExp(
      r'.+data-original="(.+?)".*data-id="(\d+)".*<div class="song-list-name"><a\s.*?>(.+?)<\/a>.+<i class="iconfont cf-bofangliang"><\/i>(.+?)<\/div>',
      multiLine: true);

  // https://music.migu.cn/v3/music/playlist/161044573?page=1
  static RegExp listDetailLink = RegExp(r'^.+\/playlist\/(\d+)(?:\?.*|&.*$|#.*$|$)', multiLine: true);

  static Map cachedUrl = {};

  static const String successCode = '000000';

  static Future getListDetail(String id, int page) async {
    // https://h5.nf.migu.cn/app/v4/p/share/playlist/index.html?id=184187437&channel=0146921
    // http://c.migu.cn/00bTY6?ifrom=babddaadfde4ebeda289d671ab62f236
    if (RegExp(r'playlist/index\.html\?').hasMatch(id)) {
      id = id.replaceFirst(RegExp(r'.*(?:\?|&)id=(\d+)(?:&.*|$)'), r'$1');
    } else if (listDetailLink.hasMatch(id)) {
      id = id.replaceFirst(listDetailLink, r'$1');
    } else if ((RegExp(r'[?&:/]').hasMatch(id))) {
      final url = cachedUrl[id];
      return url.isNotEmpty ? getListDetail(url, page) : await getDetailUrl(id, page);
    }

    Map listData = await getListDetailList(id, page);
    var info = await getListDetailInfo(id);
    listData['info'] = info;
    return listData;
  }

  static Future getListDetailList(String id, int page) async {
    // https://h5.nf.migu.cn/app/v4/p/share/playlist/index.html?id=184187437&channel=0146921

    if (RegExp(r'playlist\/index\.html\?').hasMatch(id)) {
      id = id.replaceFirstMapped(RegExp(r'.*(?:\?|&)id=(\d+)(?:&.*|$)'), (m) => m[1].toString());
    } else if ((RegExp(r'[?&:/]').hasMatch(id))) {
      id = id.replaceFirstMapped(listDetailLink, (m) => m[1].toString());
    }

    String url = getSongListDetailUrl(id, page);
    final res = await HttpCore.getInstance().get(url, headers: defaultHeaders);
    // if (res['code'] != successCode) {
    //   return getListDetail(id, page);
    // }
    return {
      'list': AppUtil.filterMusicInfoList(res['list']),
      'page': page,
      'limit': limit_song,
      'total': res['totalCount'],
      'source': 'mg',
    };
  }

  static getSongListDetailUrl(id, page) {
    return 'https://app.c.nf.migu.cn/MIGUM2.0/v1.0/user/queryMusicListSongs.do?musicListId=${id}&pageNo=${page}&pageSize=${limit_song}';
  }

  static Future<String> getDetailUrl(String link, int page) async {
    final requestObj_listDetailLink = await HttpCore.getInstance().get(link, headers: {
      'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46'
          ' (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1',
      'Referer': link,
    });
    final location = requestObj_listDetailLink.headers['location'];

    if (location.split('?')[0] != link.split('?')[0]) {
      cachedUrl[link] = location;
      return await getListDetail(location, page);
    }
    return Future.error('link get failed');
  }

  static Map<String, DetailInfo> cachedDetailInfo = {};

  static Future getListDetailInfo(String id) async {
    if (cachedDetailInfo[id] != null) return Future.value(cachedDetailInfo[id]);
    final res = await HttpCore.getInstance()
        .get('https://c.musicapp.migu.cn/MIGUM3.0/resource/playlist/v2.0?playlistId=$id', headers: defaultHeaders);
    if(res['code'] == successCode) {

      cachedDetailInfo[id] = DetailInfo(
        name: res['data']['title'],
        imgUrl: res['data']['imgItem']['img'],
        desc: res['data']['summary'],
        author: res['data']['ownerName'],
        playCount: AppUtil.formatPlayCount(res['data']['opNumItem']['playNum']),
      );
      return cachedDetailInfo[id];
    }

  }
}
