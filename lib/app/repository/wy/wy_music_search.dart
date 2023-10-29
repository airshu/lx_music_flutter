import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/app_util.dart';
import 'package:lx_music_flutter/app/repository/wy/wy_song_repository.dart';
import 'package:lx_music_flutter/models/music_item.dart';

class WYMusicSearch {
  static Future musicSearch(String str, [int page = 1, int limit = 10]) async {
    String url = '/api/cloudsearch/pc';

    var data = {
      's': str,
      'type': 1, // 1: 单曲, 10: 专辑, 100: 歌手, 1000: 歌单, 1002: 用户, 1004: MV, 1006: 歌词, 1009: 电台, 1014: 视频
      'limit': limit,
      'total': page == 1,
      'offset': limit * (page - 1),
    };
    var res = await WYSongRepository.eapiRequest(url, data);
    return res;
  }

  static List<MusicItem> handleResult(rawData) {
    if (rawData == null) {
      return [];
    }
    List<MusicItem> list = [];
    for (var item in rawData) {
      List types = [];
      Map _types = {};
      dynamic size;
      if (item['privilege']['maxBrLevel'] == 'hires') {
        size = item['hr'] != null ? AppUtil.sizeFormate(item['hr']['size']) : 0;
        types.add({'type': 'flac24bit', 'size': size});
        _types['flac24bit'] = {'size': size};
      }

      switch (item['privilege']['maxbr']) {
        case 999000:
          size = item['sq'] != null ? AppUtil.sizeFormate(item['sq']['size']) : 0;
          types.add({'type': 'flac', 'size': size});
          _types['flac'] = {'size': size};
          break;
        case 320000:
          size = item['h'] != null ? AppUtil.sizeFormate(item['h']['size']) : 0;
          types.add({'type': '320k', 'size': size});
          _types['320k'] = {'size': size};
          break;
        case 192000:
        case 128000:
          size = item['l'] != null ? AppUtil.sizeFormate(item['l']['size']) : 0;
          types.add({'type': '128k', 'size': size});
          _types['128k'] = {'size': size};
          break;
      }

      list.add(MusicItem(
        singer: getSinger(item['ar']),
        name: item['name'],
        albumName: item['al']['name'],
        albumId: item['al']['id'],
        songmid: item['id'],
        source: AppConst.sourceWY,
        interval: AppUtil.formatPlayTime(item['dt'] ?? 0 / 1000),
        img: item['al']['picUrl'],
        qualityList: types,
        qualityMap: _types,
        urlMap: {},
        lrc: '',
      ));

      // list.add({
      //   'singer': getSinger(item['ar']),
      //   'name': item['name'],
      //   'ablumName': item['al']['name'],
      //   'albumId': item['al']['id'],
      //   'source': AppConst.sourceWY,
      //   'interval': AppUtil.formatPlayTime(item['dt'] ?? 0 / 1000),
      //   'songId': item['id'],
      //   'img': item['al']['picUrl'],
      //   'lrc': null,
      //   'types': types,
      //   '_types': _types,
      //   'typeUrl': {},
      // });
    }

    return list;
  }

  static String getSinger(singers) {
    List arr = [];
    singers.forEach((s) {
      arr.add(s['name']);
    });
    return arr.join('、');
  }

  static Future<MusicModel> search(String str, [int page = 1, int limit = 10]) async {
    var res = await musicSearch(str, page, limit);
    List<MusicItem> list = handleResult(res['result']['songs']);
    int total = res['data']['total'];
    int allPage = (total / limit).ceil();
    return MusicModel(list: list, allPage: allPage, total: total, source: AppConst.sourceWY);
  }
}
