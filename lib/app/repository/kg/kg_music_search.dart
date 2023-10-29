import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/app_util.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';

class KGMusicSearch {
  static Future musicSearch(String str, [int page = 1, int limit = 10]) async {
    String url =
        'https://songsearch.kugou.com/song_search_v2?keyword=${Uri.encodeComponent(str)}&page=${page}&pagesize=${limit}&userid=0&clientver=&platform=WebFilter&filter=2&iscorrection=1&privilege_filter=0';
    var res = await HttpCore.getInstance().get(url);
    return res;
  }

  static MusicItem filterData(rawData) {
    List qualityList = [];
    Map qualityMap = {};
    dynamic size;
    if (rawData['FileSize'] != null) {
      size = AppUtil.sizeFormate(rawData['FileSize']);
      qualityList.add({
        'type': '128k',
        'size': size,
        'hash': rawData['FileHash'],
      });
      qualityMap['128k'] = {
        'size': size,
        'hash': rawData['FileHash'],
      };
    }

    if (rawData['HQFileSize'] != null) {
      size = AppUtil.sizeFormate(rawData['HQFileSize']);
      qualityList.add({
        'type': '320k',
        'size': size,
        'hash': rawData['HQFileHash'],
      });
      qualityMap['320k'] = {
        'size': size,
        'hash': rawData['HQFileHash'],
      };
    }
    if (rawData['SQFileSize'] != null) {
      size = AppUtil.sizeFormate(rawData['SQFileSize']);
      qualityList.add({
        'type': 'flac',
        'size': size,
        'hash': rawData['SQFileHash'],
      });
      qualityMap['flac'] = {
        'size': size,
        'hash': rawData['SQFileHash'],
      };
    }
    if (rawData['ResFileSize'] != null) {
      size = AppUtil.sizeFormate(rawData['ResFileSize']);
      qualityList.add({
        'type': 'flac24bit',
        'size': size,
        'hash': rawData['ResFileHash'],
      });
      qualityMap['flac24bit'] = {
        'size': size,
        'hash': rawData['ResFileHash'],
      };
    }

    return MusicItem(
      singer: AppUtil.decodeName(AppUtil.formatSingerName(singers: rawData['Singers'])),
      name: AppUtil.decodeName(rawData['SongName']),
      albumName: AppUtil.decodeName(rawData['AlbumName']),
      albumId: '${rawData['AlbumID']}',
      songmid: '${rawData['Audioid']}',
      source: AppConst.sourceKG,
      interval: AppUtil.formatPlayTime(rawData['Duration']),
      img: '',
      lrc: '',
      otherSource: '',
      hash: rawData['FileHash'],
      qualityList: qualityList,
      qualityMap: qualityMap,
      urlMap: {},
    );
    // return {
    //   'singer':AppUtil.decodeName(AppUtil.formatSingerName(singers: rawData['Singers'])),
    //   'name': AppUtil.decodeName(rawData['SongName']),
    //   'albumName': AppUtil.decodeName(rawData['AlbumName']),
    //   'albumId': rawData['AlbumID'],
    //   'songmid': rawData['Audioid'],
    //   'source': AppConst.sourceKG,
    //   'interval': AppUtil.formatPlayTime(rawData['Duration']),
    //   '_interval': rawData['Duration'],
    //   'img': null,
    //   'lrc': null,
    //   'otherSource': null,
    //   'hash': rawData['FileHash'],
    //   'types': types,
    //   '_types': _types,
    //   'typeUrl': {},
    // };
  }

  static Future<MusicModel> search(String str, [int page = 1, int limit = 10]) async {
    var res = await musicSearch(str, page, limit);
    List<MusicItem> list = handleResult(res['data']['lists']);
    int total = res['data']['total'];
    int allPage = (total / limit).ceil();
    return MusicModel(
      list: list,
      allPage: allPage,
      total: total,
      source: AppConst.sourceKG,
    );
  }

  static List<MusicItem> handleResult(rawData) {
    Map ids = {};
    List<MusicItem> list = [];
    for (var item in rawData) {
      var key = '${item['Audioid']}${item['FileHash']}';
      if (ids.containsKey(key)) {
        break;
      }
      ids[key] = '';
      list.add(filterData(item));
      for (var childItem in item['Grp']) {
        var key = '${item['Audioid']}${item['FileHash']}';
        if (ids.containsKey(key)) {
          break;
        }
        list.add(filterData(childItem));
      }
    }
    return list;
  }
}
