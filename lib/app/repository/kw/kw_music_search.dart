import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/app_util.dart';
import 'package:lx_music_flutter/models/search_model.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';

class KWMusicSearch {
  static Future musicSearch(String str, [int page = 1, int limit = 10]) async {
    String url =
        'http://search.kuwo.cn/r.s?client=kt&all=${Uri.encodeComponent(str)}&pn=${page - 1}&rn=${limit}&uid=794762570&ver=kwplayer_ar_9.2.2.1&vipver=1&show_copyright_off=1&newver=1&ft=music&cluster=0&strategy=2012&encoding=utf8&rformat=json&vermerge=1&mobi=1&issubtitle=1';
    var res = await HttpCore.getInstance().get(url);
    return res;
  }

  static Future<SearchMusicModel> search(String str, [int page = 1, int limit = 10]) async {
    var res = await musicSearch(str, page, limit);
    List<SearchItem> list = handleResult(res['data']['lists']);
    int total = res['data']['total'];
    int allPage = (total / limit).ceil();
    return SearchMusicModel(list: list, allPage: allPage, total: total, source: AppConst.sourceKW);
  }

  static RegExp minfo = RegExp(r'/level:(\w+),bitrate:(\d+),format:(\w+),size:([\w.]+)/');

  static List<SearchItem> handleResult(rawData) {
    List<SearchItem> result = [];
    if (rawData == null) {
      return [];
    }
    for (var info in rawData) {
      var songId = info['MUSICRID'].replaceAll('MUSIC_', '');
      if (info['N_MINFO'] == null) {
        return [];
      }
      List qualityList = [];
      Map qualityMap = {};
      List infoArr = info['N_MINFO'].split(';');
      for (var item in infoArr) {
        Iterable<RegExpMatch> it = minfo.allMatches(item);
        if (it.isNotEmpty) {
          switch (it.elementAtOrNull(2)!.group(2)!) {
            case '4000':
              qualityList.add({'type': 'flac24bit', 'size': it.elementAtOrNull(4)});
              qualityMap['flac24bit'] = {'size': it.elementAtOrNull(4)};
              break;
            case '2000':
              qualityList.add({'type': 'flac', 'size': it.elementAtOrNull(4)});
              qualityMap['flac'] = {'size': it.elementAtOrNull(4)};
              break;
            case '320':
              qualityList.add({'type': '320k', 'size': it.elementAtOrNull(4)});
              qualityMap['320k'] = {'size': it.elementAtOrNull(4)};
              break;
            case '128':
              qualityList.add({'type': '128k', 'size': it.elementAtOrNull(4)});
              qualityMap['128k'] = {'size': it.elementAtOrNull(4)};
              break;
          }
        }
      }
      result.add(SearchItem(
        albumName: '',
        hash: '',
        urlMap: {},
        name: AppUtil.decodeName(info['SONGNAME']),
        singer: AppUtil.formatSinger(AppUtil.decodeName(info['ARTIST'])),
        songmid: songId,
        albumId: AppUtil.decodeName(info['ALBUMID'] ?? ''),
        interval: AppUtil.formatPlayTime(info['DURATION'] ?? 0),
        lrc: '',
        img: '',
        otherSource: '',
        qualityList: qualityList,
        qualityMap: qualityMap,
        source: AppConst.sourceKW,
      ));
      // result.add({
      //   'name': AppUtil.decodeName(info['SONGNAME']),
      //   'singer': AppUtil.formatSinger(AppUtil.decodeName(info['ARTIST'])),
      //   'songmid': songId,
      //   'albumId': AppUtil.decodeName(info['ALBUMID'] ?? ''),
      //   'interval': AppUtil.formatPlayTime(info['DURATION'] ?? 0),
      //   'lrc': null,
      //   'img': null,
      //   'otherSource': null,
      //   'types': qualityList,
      //   '_types': qualityMap,
      //   'typeUrl': {},
      //   'source': AppConst.sourceKW,
      // });
    }

    return result;
  }
}
