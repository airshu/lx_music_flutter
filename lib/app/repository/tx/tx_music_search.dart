import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/app_util.dart';
import 'package:lx_music_flutter/models/music_item.dart';

/// 腾讯根据关键字搜索歌曲
class TXMusicSearch {
  static Future musicSearch(String str, [int page = 1, int limit = 10]) async {
    String url = 'https://u.y.qq.com/cgi-bin/musicu.fcg';
    var headers = {
      'User-Agent': 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)',
    };

    var body = {
      'comm': {
        'ct': 11,
        'cv': '1003006',
        'v': '1003006',
        'os_ver': '12',
        'phonetype': '0',
        'devicelevel': '31',
        'tmeAppID': 'qqmusiclight',
        'nettype': 'NETWORK_WIFI',
      },
      'req': {
        'module': 'music.search.SearchCgiService',
        'method': 'DoSearchForQQMusicLite',
        'param': {
          'query': str,
          'search_type': 0,
          'num_per_page': limit,
          'page_num': page,
          'nqc_flag': 0,
          'grp': 1,
        },
      },
    };

    Response res = await Dio().post(url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: headers,
        ),
        data: body);
    String jsonStr = const Utf8Decoder().convert(res.data);
    Map tagMap = json.decode(jsonStr);
    return tagMap['req']['data'];
  }

  static List<MusicItem> handleResult(rawData) {
    List<MusicItem> list = [];
    for (var item in rawData) {
      List types = [];
      Map _types = {};
      dynamic size;
      var file = item['file'];
      if (file['size_128mp3'] != null) {
        size = AppUtil.sizeFormate(file['size_128mp3']);
        types.add({'type': '128k', 'size': size});
        _types['128k'] = {'size': size};
      }
      if (file['size_320mp3'] != null) {
        size = AppUtil.sizeFormate(file['size_320mp3']);
        types.add({'type': '320k', 'size': size});
        _types['320k'] = {'size': size};
      }
      if (file['size_flac'] != null) {
        size = AppUtil.sizeFormate(file['size_flac']);
        types.add({'type': 'flac', 'size': size});
        _types['flac'] = {'size': size};
      }
      if (file['size_hires'] != null) {
        size = AppUtil.sizeFormate(file['size_hires']);
        types.add({'type': 'flac24bit', 'size': size});
        _types['flac24bit'] = {'size': size};
      }

      String albumId = '';
      String albumName = '';
      if (item['album'] != null) {
        albumId = item['album']['mid'];
        albumName = item['album']['name'];
      }
      list.add(MusicItem(
        singer: AppUtil.formatSingerName(singers: item['singer']),
        name: item['name'] + item['title_extra'] ?? '',
        albumName: albumName,
        albumId: albumId,
        songmid: item['mid'],
        source: AppConst.sourceTX,
        interval: AppUtil.formatPlayTime(item['interval']),
        img: (albumId == '' || albumId == '空')
            ? item['singer'] != null
                ? 'https://y.gtimg.cn/music/photo_new/T001R500x500M000${item['singer'][0]['mid']}.jpg'
                : ''
            : 'https://y.gtimg.cn/music/photo_new/T002R500x500M000${albumId}.jpg',
        qualityList: types,
        qualityMap: _types,
        urlMap: {},
      ));
    }

    return list;
  }

  static Future search(String str, [int page = 1, int limit = 10]) async {
    var res = await musicSearch(str, page, limit);
    List<MusicItem> list = handleResult(res['body']['item_song']);
    int total = res['meta']['estimate_sum'];
    int allPage = (total / limit).ceil();
    return MusicModel(list: list, allPage: allPage, total: total, source: AppConst.sourceTX);
  }
}
